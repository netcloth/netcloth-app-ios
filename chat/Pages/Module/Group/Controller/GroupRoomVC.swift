  
  
  
  
  
  
  

import UIKit
import IQKeyboardManagerSwift


  
class GroupRoomVC:BaseViewController,
    UITableViewDelegate, UITableViewDataSource,
    ChatDelegate,
    KeyboardManagerDelegate,
    ChatCommonCellDelegate,
    SDPhotoBrowserDelegate
{
    let groupRoomService = GroupRoomService()
    var chatContact: CPContact? {
        didSet {
            self.roomService = groupRoomService
            groupRoomService.chatContact = StoreObservable(value: (self.chatContact)!)
            
            GroupRoomService.sessionId = Int(self.chatContact?.sessionId ?? 0)
            GroupRoomService.toPublicKey = self.chatContact?.publicKey
            GroupRoomService.remark = self.chatContact?.remark
            
            CPChatHelper.setRoomToPubkey(self.chatContact?.publicKey)
        }
    }
    
    fileprivate var sessionId: Int? {
        get {
            return Int(self.chatContact?.sessionId ?? 0)
        }
    }
    fileprivate var toPublicKey: String? {
        get {
            return self.chatContact?.publicKey
        }
    }
    fileprivate var remark: String? {
        get {
            return self.chatContact?.remark
        }
    }
    
      
    @IBOutlet weak var toolbarBottomToSafe: NSLayoutConstraint!
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: ChatToolBar!
    
    @IBOutlet weak var notFoundTipContainer: UIView?
    @IBOutlet weak var notExistL: UILabel?
    
    @IBOutlet weak var unreadLocationV: UIView?
    @IBOutlet weak var unreadCountTipsLabel: UILabel?
    
    var rightBarItem: UIBarButtonItem?
    
      
      
    var messageArray: [CPMessage] = []
    var synManager: GroupMsgSynchronize?
    
    var last_big_msg_id : Int64 = 0
    
      
    private var lastMsgId: Int64 = 1
    
    let disbag = DisposeBag()
    
    var msgPatchQueue : DispatchQueue = OS_dispatch_queue_serial(label: "com.groupchat.room.msg", qos: .default)
    
      
    var lastOpenTime: Double = Date().timeIntervalSince1970
    
      
    
    deinit {
        if RoomStatus.toPublicKey == self.toPublicKey {
            RoomStatus.toPublicKey = nil
            CPChatHelper.setRoomToPubkey(nil)
        }
        
        IQKeyboardManager.shared.disabledToolbarClasses.removeLast()
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        SRRecordingAudioPlayerManager.shared()?.stop()
        CPChatHelper.removeInterface(self)
        
        Router.rootWindow?.endEditing(true)
    }
    
    var cellPlaceHolders: [String: ChatCommonCell] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)]
        
          
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses.append(type(of: self))
        
        KeyboardManager.shared.setObserver(self)
        
        messageArray = []
        configUI()
        configEvent()
        self.showLoading()
        fetchDataMsg(createtime: -1, server_msg_id: -1)
        
        CPChatHelper.addInterface(self)
        calculateCells()
        
        self.roomService?.requestGroupInfo()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.showBlackLine()
        RoomStatus.inChatRoom = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setSessionToRead()
        RoomStatus.inChatRoom = false
        
        self.toolBar.textField.resignFirstResponder()
        self.view.endEditing(true)
    }
        
    func configUI() {
        
        let right = UIBarButtonItem(image: UIImage(named: "room_info_more"), style: .plain, target: self, action: #selector(toQuerySessionCard))
        rightBarItem = right
        self.navigationItem.rightBarButtonItem = right
        
        tableView.refreshControl = refreshControl
          
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        tableView.adjustFooter()
        tableView.adjustOffset()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let longgesture = UILongPressGestureRecognizer { [weak self] (gesture) in
            self?.onTriggerLongGesture(gesture as? UILongPressGestureRecognizer)
        }
        longgesture.minimumPressDuration = 1
        tableView.addGestureRecognizer(longgesture)
        
        self.unreadLocationV?.setShadow(color: UIColor(hexString: "#606266")!, offset: CGSize(width: 0, height: 1), radius: 3, opacity: 0.2)
    }
    
    func configEvent() {
        
        refreshControl.addTarget(self, action: #selector(loadHistroy), for: UIControl.Event.valueChanged)
        
        self.toolBar.publish.subscribe { [weak self] (event: Event<Any?>) in
            if self?.toPublicKey == nil {
                return
            }
            if let t = event.element as? String {
                self?.sendMsg(text: t)
            }
            else if let d = event.element as? Data {
                self?.sendAudio(data: d)
            }
            else if let dic = event.element as? NSDictionary {
                if let imgdata = dic["image"] as? Data {
                    self?.sendImage(data: imgdata)
                }
            }
        }.disposed(by: disbag)
    
        self.roomService?.chatContact?.observable.subscribe(onNext: { [weak self] (e) in
            self?.judgeChanges()
        }).disposed(by: disbag)
        
        self.roomService?.isMeGroupMaster.subscribe(onNext: { [weak self] (e) in
            self?.judgeChanges()
        }).disposed(by: disbag)
        
        NotificationCenter.default.rx.notification( UIMenuController.didHideMenuNotification).subscribe(onNext: { [weak self] (notice) in
            self?.notInMenu = true
        }).disposed(by: disbag)

        NotificationCenter.default.rx.notification( NoticeNameKey.chatRecordDeletes.noticeName).subscribe(onNext: { [weak self] (notice) in
            if let pubkey = notice.object as? String, pubkey == self?.toPublicKey {
                self?.onHandleDeleteAllChatRecored()
            }
        }).disposed(by: disbag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetRegisterOk), name: NSNotification.Name.serviceRegisterOk, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_onTriggerUnreadChange), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func _onTriggerUnreadChange() {
        self.setSessionToRead()
        NotificationCenter.post(name: NoticeNameKey.chatRoomUnreadStatusChange)
    }
      
    
    func calculateCells() {
        let suppert = ["OtherUnknown","SelfUnknown",
                       "OtherText","SelfText",
                       "OtherAudio","SelfAudio",
                       "SelfImage","OtherImage",
                       "SystemMsgCell"]
        
        var cell: ChatCommonCell?
        for iden in suppert {
            cell = self.tableView.dequeueReusableCell(withIdentifier: iden) as? ChatCommonCell
            cell?.width = YYScreenSize().width
            cellPlaceHolders[iden] = cell
        }
    }
    
    func judgeChanges() {
        
        guard let pubkey = self.toPublicKey else {
            return
        }
        let contact = self.roomService?.chatContact?.value
        
        let groupName = self.remark ?? ""
        var memberCount = self.roomService?.groupAllMember?.count ?? 0
        
        if contact?.groupProgress == GroupCreateProgress.dissolve ||
        contact?.groupProgress == GroupCreateProgress.kicked {
            memberCount = 0
        }
        
        var title = "\(groupName)(\(memberCount))"
        
        if contact?.isDoNotDisturb == true {
            self.setTitleImage(title, image: UIImage(named: "room_not_disturb")!)
        } else {
            self.setCustomTitle(title)
        }
        
        if contact?.groupProgress == GroupCreateProgress.dissolve {
            self.notExistL?.text = "Group_Dissolve_tip".localized()
            self.notFoundTipContainer?.isHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.toolBar.resetLock(lock: true, lockStr: "chat_group_dismissed".localized())
        }
        else if contact?.groupProgress == GroupCreateProgress.kicked {
            self.notExistL?.text = "Group_Kick_tip".localized()
            self.notFoundTipContainer?.isHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.toolBar.resetLock(lock: true, lockStr: "chat_group_kicked".localized())
        }
        
        else {
            self.notFoundTipContainer?.isHidden = true
            self.navigationItem.rightBarButtonItem = rightBarItem
            self.toolBar.resetLock(lock: false, lockStr: nil)
        }
    }
    
    @objc func toQuerySessionCard() {
        if let vc = R.loadSB(name: "GroupDetail", iden: "GroupDetailVC") as? GroupDetailVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    @objc func resetRegisterOk() {
        lastOpenTime = Date().timeIntervalSince1970
        var tmpLastMsgId = findLastOpenMsgId()
        synManager?.resetStart(openMsgId: tmpLastMsgId)
    }
    
    func findLastOpenMsgId() -> Int64 {
        var tmpLastMsgId: Int64 = 0
        let tmpArray = self.messageArray.reversed()   
        for item in tmpArray {
            if item.isDelete != 2 && item.read == true {
                tmpLastMsgId = item.server_msg_id
                break
            }
        }
        return tmpLastMsgId
    }
    
    @IBAction func onActionToLastOpenMsgId() {
        self.unreadLocationV?.isHidden = true
        
        var toRow = 0
        for (index , item) in self.messageArray.enumerated() {
            if item.server_msg_id == self.synManager?.const_open_msg_id {
                toRow = index
                break
            }
        }
        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: IndexPath(row: toRow, section: 0), at: .top, animated: true)
        }
    }
    
    @objc func setSessionToRead() {
        CPSessionHelper.setAllReadOfSession(sessionId ?? 0, with: SessionType.group, complete: nil)
    }
    
      
    @objc func loadHistroy() {
        if  let msg = messageArray.first {
            fetchDataMsg(createtime: msg.createTime, server_msg_id: msg.server_msg_id)
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func fetchDataMsg(createtime: Double ,server_msg_id: CLongLong) {
          
        CPGroupManagerHelper.v2GetMessages(inSession: sessionId ?? 0, beforeCreateTime: createtime, beforeServerId: server_msg_id, size: 17) {
            [weak self] (ok, msg, array: [CPMessage]?) in
            
            self?.msgPatchQueue.async {
                
                  
                if let toarray = array {
                    for to in toarray {
                        to.msgDecodeContent()
                    }
                }
                
                DispatchQueue.main.async {
                    self?.dismissLoading()
                    self?.refreshControl.endRefreshing()
                    
                    self?._onHandleMsgsData(array ?? [], complete: {
                          
                        if server_msg_id == -1 || createtime == -1 {
                            self?._refreshToBottom()
                            
                              
                            if self?.synManager == nil {
                                self?.setupSynVm()
                            }
                        }
                        else {
                            if array?.isEmpty == false {
                                self?._refreshToTop()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func setupSynVm() {
        var tmpLastMsgId = self.findLastOpenMsgId() ?? 0
        self.synManager = GroupMsgSynchronize(room: self, openMsgId: tmpLastMsgId)
        self.synManager?.unreadCountCallBack = { [weak self] count in
            self?.unreadCountCallBack(count)
        }
    }
    
    func unreadCountCallBack(_ count: Int64) -> Void  {
        print("syn group message unreadCount \(count)")
        if count > 0 {
            self.unreadLocationV?.isHidden = false
            var tip = "Group_syn_msg_count".localized()
            tip = tip.replacingOccurrences(of: "#mark#", with: "\(count)")
            self.unreadCountTipsLabel?.text = tip
            addFakeLocationTip()
        }
        else {
            self.unreadLocationV?.isHidden = true
        }
    }
    
    func addFakeLocationTip() {
          
        let locationTip = "Group_unread_location_tip".localized()
        var createTime: Double = 0
        
        let fakeMsg = CPMessage()
        fakeMsg.msgType = .welcomNewFriends
        fakeMsg.toPubkey = self.toPublicKey ?? ""
        fakeMsg.msgData = locationTip.data(using: String.Encoding.utf8)
        
        let msgid = self.synManager?.const_open_msg_id ?? 0
        fakeMsg.server_msg_id = msgid
        
        let tmpArray = self.messageArray.reversed()   
        for item in tmpArray {
            if item.server_msg_id == msgid {
                createTime = item.createTime
                fakeMsg.signHash = item.signHash
                break
            }
        }
        
        fakeMsg.createTime = createTime + 0.001
        
        msgPatchQueue.async {
            self._insertMsg(fakeMsg, atLast: true)
            DispatchQueue.main.async {
                self.reloadTableView()
            }
        }
    }
    
      
    @objc func _refreshVisibleCells() {
        self.msgPatchQueue.async {
            self.reloadTableView()
        }
    }
    
    func _refreshToBottom(animate:Bool = false) {
        self.reloadTableView()
        DispatchQueue.main.async {
            if (self.tableView.contentSize.height - self.tableView.bounds.size.height) > 0 {
                self.tableView.scrollToBottom(animated: animate)
            }
        }
    }
    
      
    func _refreshToTop() {
        let tmpId = lastMsgId
        self.reloadTableView()
        var toRow = 0
        for (index , item) in self.messageArray.enumerated() {
            if item.msgId == tmpId {
                toRow = index
                break
            }
        }
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            self.tableView.scrollToRow(at: IndexPath(row: toRow, section: 0), at: .middle, animated: false)
            self.tableView.isHidden = false
        }
    }
    
    fileprivate func reloadTableView() {
        if Thread.isMainThread {
            self.tableView.reloadData()
        } else {
            DispatchQueue.main.sync {
                self.tableView.reloadData()
            }
        }
    }
    
      
    func onHandleRemarkChange(contact: CPContact) {
        msgPatchQueue.async { [weak self] in
              
        }
    }
    
    func onHandleDeleteAllChatRecored() {
        msgPatchQueue.async(flags: .barrier) {
            self.messageArray = []
            self.reloadTableView()
        }
    }
    
    
      
    private var menuOpItem: CPMessage?
    private var menuController: UIMenuController?
    private var notInMenu: Bool = true
    
    func checkEnableToBottom() -> Bool {
        let diff = self.tableView.contentSize.height - self.tableView.contentOffset.y
        let diffPage = abs(diff) < (self.tableView.height * 2)
        
        return notInMenu && diffPage
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(itemCopy) {
            return true
        }
        if action == #selector(itemDelete) {
            return true
        }
        return false
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    @objc func itemCopy() {
        guard let content = menuOpItem?.msgDecodeContent() as? String else {
            return
        }
        UIPasteboard.general.string = content
        Toast.show(msg: NSLocalizedString("Copy Share", comment: ""))
        self._refreshToBottom()
    }
    
    @objc func itemDelete() {
        guard let msg = menuOpItem else {
            return
        }
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
              
            alert.titleLabel?.text = NSLocalizedString("Session_W_Title", comment: "")
            alert.msgLabel?.text = NSLocalizedString("Session_W_Msg", comment: "")
            alert.cancelButton?.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
            alert.okButton?.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = { [weak self] in
                self?.msgPatchQueue.async {
                    guard let idx = self?.messageArray.firstIndex(of: msg) else { return }
                    self?.messageArray.remove(at: idx)
                    self?.reloadTableView()
                    
                    CPGroupManagerHelper.deleteMessage(msg.msgId, complete: nil)
                }
            }
        }
        
    }
    
    func showMenuAtCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        
        if menuController == nil {
            menuController = UIMenuController.shared
            menuController?.arrowDirection = .default
        }
        
        guard let msg = self.messageArray[safe: indexPath.row] else { return }
        guard let chatCell = cell as? ChatCommonCell else { return }
        menuOpItem = msg
        var items:[UIMenuItem] = []
        if msg.msgType == .text {
            let cp = UIMenuItem(title: NSLocalizedString("Copy", comment: ""), action: #selector(itemCopy))
            items.append(cp)
        }
        let del = UIMenuItem(title: NSLocalizedString("Delete", comment: ""), action: #selector(itemDelete))
        items.append(del)
        menuController?.menuItems = items
        var frame = chatCell.frame
        if let mc = chatCell.msgContentView() {
            if let tof = mc.superview?.convert(mc.frame, to: self.tableView) {
                frame = tof
            }
        }
        else {
            return
        }
        
        menuController?.setTargetRect(frame, in: self.tableView)
        menuController?.setMenuVisible(true, animated: true)
        self.notInMenu = false
    }
    func dismssMenu() {
        menuController?.setMenuVisible(false, animated: true)
    }
    
    func onTriggerLongGesture(_ ges: UILongPressGestureRecognizer?) {
        guard  let recognizer = ges else { return }
        if recognizer.state == .began {
            let location = recognizer.location(in: self.tableView)
            guard let indexPath = self.tableView.indexPathForRow(at: location) else { return }
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            
              
            showMenuAtCell(cell,at: indexPath)
        }
    }
    
      
      
    func onCacheMsgRecieve(_ caches: [CPMessage]!) {
        _onHandleMsgsData(caches) { [weak self] in
            self?._refreshToTop()
        }
    }
    
    func onMsgSendStateChange(_ msgTmp: CPMessage) {
        msgPatchQueue.async {
            for msg in self.messageArray.reversed() {
                if msg.msgId == msgTmp.msgId {
                    msg.toServerState = msgTmp.toServerState
                    if msgTmp.server_msg_id > 0 {
                        msg.server_msg_id = msgTmp.server_msg_id
                    }
                    self._refreshVisibleCells()
                    if msgTmp.toUserNotFound {
                        DispatchQueue.main.async {
                            self.notFoundTipContainer?.isHidden = false
                        }
                    }
                    break
                }
            }
        }
    }
        
      
    func onReceiveMsg(_ msg: CPMessage) {
        self._onHandleMsgsData([msg], isOnline: true) { [weak self] in
              
            if self?.checkEnableToBottom() == true {
                self?._refreshToBottom(animate: true)
            }
        }
    }
    
      
    
    func onCurrentRoomInfoChange() {
        CPContactHelper.getOneContact(byPubkey: self.toPublicKey) { [weak self] (r, msg, contact) in
            if let c = contact {
                self?.roomService?.chatContact?.change(commit: { (ct) in
                    ct.remark = c.remark
                    ct.inviteType = c.inviteType
                    
                    ct.notice_encrypt_content = c.notice_encrypt_content
                    ct.notice_modified_time = c.notice_modified_time
                    ct.notice_publisher = c.notice_publisher
                    
                    ct.groupProgress = c.groupProgress
                    
                })
            }
        }
        
        let sessionId = self.sessionId ?? 0
        CPGroupManagerHelper.getAllMemberList(inGroupSession: sessionId) { [weak self] (r, msg, members) in
            if r {
                self?.roomService?.groupAllMember = members
            }
        }
    }

    
    func onReceiveGroupChatMsgs(_ msgs: [CPMessage]) {
        let isCache = (msgs.last?.createTime ?? 0) < self.lastOpenTime
        self._onHandleMsgsData(msgs, isOnline: true) { [weak self] in
              
            if isCache {
                self?._refreshToTop()
            }
            else {
                if self?.checkEnableToBottom() == true {
                    self?._refreshToBottom(animate: true)
                }
            }
        }
    }
    
    
      
    func _onHandleMsgsData(_ data: [CPMessage],
                           isOnline: Bool = false,
                           complete: (() -> Void)?) {
        
        msgPatchQueue.async { [weak self] in
            if data.isEmpty {
                DispatchQueue.main.async {
                    complete?()
                }
                return
            }
              
            var accept = [CPMessage]()
            for tmp in data {
                if self?.shouldReceiveMsg(tmp) == true {
                    accept.append(tmp)
                }
            }
            
              
            accept = self?._deleteRepeatInDataArray(wantInArray: accept) ?? []
            
            guard accept.count > 0 else {
                DispatchQueue.main.async {
                    complete?()
                }
                return
            }
            
              
            let members = self?.roomService?.groupAllMember ?? []

            accept.forEach { (msg) in
                msg.msgDecodeContent()
                
                  
                var find = false
                for item in members {
                    if item.hexPubkey == msg.senderPubKey {
                        msg.senderRemark = item.nickName
                        find = true
                        break
                    }
                }
                if find == false {
                    msg.senderRemark = msg.senderPubKey
                }
            }
            
              
            self?._orderMsgs(inArray: &accept)
            
              
            var last:CPMessage? = nil;
            for tmp in accept {
                if last == nil {
                    if isOnline {
                        let diff = tmp.createTime - (self?.messageArray.last?.createTime ?? 0)
                        if diff >= Double(Config.Time_Diff) {
                            tmp.showCreateTime = true
                        }
                    } else {
                        tmp.showCreateTime = true
                    }
                }
                else {
                    let diff = tmp.createTime - (last?.createTime ?? 0)
                    if (fabs(diff) >= Double(Config.Time_Diff)) {
                        tmp.showCreateTime = true
                    }
                }
                last = tmp;
            }
            
              
            if isOnline {
                self?._insertMsgs(accept, atLast: false)
            } else {
                self?._insertMsgs(accept, atLast: true)
            }
            
              
            DispatchQueue.main.async {
                complete?()
            }
        }
    }
    
    func shouldReceiveMsg(_ msg: CPMessage) -> Bool {
        if (msg.toPubkey == self.toPublicKey) {
            return true
        }
        return false
    }
    
    func _deleteRepeatInDataArray(wantInArray: [CPMessage]) -> [CPMessage] {
        var toInsertA: [CPMessage] = []
        for toIn in wantInArray {
            var toAdd: Bool = true
            for haved in messageArray {
                if toIn.signHash == haved.signHash &&
                    toIn.server_msg_id == haved.server_msg_id {
                    toAdd = false
                }
            }
            if toAdd {
                toInsertA.append(toIn)
            }
        }
        return toInsertA
    }
    
    func _orderMsgs(inArray arr: inout [CPMessage]) {
        try?
            arr.sort(by: { (m1, m2) -> Bool in
                if m1.createTime < m2.createTime {
                    return true
                }
                if (m1.createTime >= m2.createTime) && (m1.server_msg_id < m2.server_msg_id) {
                    return true
                }
                return false
            })
    }
    
    func _insertMsg(_ msg: CPMessage, atLast: Bool = true) {
        _insertMsgs([msg], atLast: atLast)
    }
    
    func _insertMsgs(_ msg: [CPMessage], atLast: Bool = true) {
        
        guard msg.count > 0 else {
            return
        }
        
          
        if atLast {
            messageArray.append(contentsOf: msg)
        } else {
            messageArray.insert(contentsOf: msg, at: 0)
        }
        
          
        _orderMsgs(inArray: &messageArray)
    }
    
    
      
    func onTapAvatar(pubkey: String) {
        
        if pubkey == support_account_pubkey {
            return
        }
        if let vc = R.loadSB(name: "GroupMemberCard", iden: "GroupMemberCardVC") as? GroupMemberCardVC {
            vc.contactPublicKey = pubkey
            vc.sourceTag = 1
            Router.pushViewController(vc: vc)
        }
    }
    func onRetrySendMsg(_ msgId: CLongLong) {
        if let alert = R.loadNib(name: "RetrySendAlert") as? RetrySendAlert {
              
            alert.titleLabel?.text = "Resend the message？".localized()
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            alert.okBlock = {
                CPGroupManagerHelper.retrySendMsg(msgId)
            }
            Router.showAlert(view: alert)
        }
    }
    
    var toShowImage: UIImage?
    func onShowBigPhoto(_ img: UIImage, containerView: UIView) {
        self.view.endEditing(true)
        toShowImage = img
        let pb = SDPhotoBrowser()
        pb.imageCount = 1
        pb.sourceImagesContainerView = containerView
        if let cell = containerView as? GroupImageChatCell {
            pb.sourceImgView = cell.pictureImage
        }
        
        pb.delegate = self
        pb.show()
    }
    
    func photoBrowser(_ browser: SDPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        return toShowImage ?? UIImage()
    }
    
      
    
    func sendMsg(text: String) {
        CPGroupChatHelper.sendText(text, toGroup: toPublicKey!)
    }
    
    func sendAudio(data: Data) {
        CPGroupChatHelper.sendAudioData(data , toGroup: toPublicKey!)
    }
    
    func sendImage(data: Data) {
        CPGroupChatHelper.sendImageData(data, toGroup: toPublicKey!)
    }
    
      
    func onKeyboardFrame(_ toframe: CGRect, dura: Double, aniCurve: Int) {
        
        if toframe.origin.y >= YYScreenSize().height {
            onKbHidden(dura: dura, aniCurve: aniCurve)
        }
        else {
            if checkCanReload() == false {
                return
            }
            onKbTop(Y: toframe.origin.y, kbH: toframe.size.height, dura: dura, aniCurve: aniCurve)
        }
    }
    
    func onKbHidden(dura: Double, aniCurve: Int) {
        self.view.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: dura, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(aniCurve)), animations: {
            [weak self] in
            self?.toolbarBottomToSafe.constant = 0
            self?.view.layoutIfNeeded()
            self?.reloadTableView()
            }, completion: nil)
    }
    
    func onKbTop(Y:CGFloat, kbH:CGFloat, dura: Double, aniCurve: Int) {
        guard kbH > 0 else {
            return
        }
        
        var diff = kbH
        if #available(iOS 11.0, *) {
            diff = kbH - self.view.safeAreaInsets.bottom
        } else {
              
        }
        
        self.view.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: dura, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(aniCurve)), animations: {
            [weak self] in
            self?.toolbarBottomToSafe.constant =  -abs(diff)
            self?.view.layoutIfNeeded()
            self?._refreshToBottom(animate: true)
            }, completion: nil)
    }
}

extension GroupRoomVC {
    
      
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startSynOfflineMsg()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            checkCanReloadMore()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkCanReloadMore()
    }
    
      
    func checkCanReloadMore() {
        if checkEnableToBottom() {
            _refreshVisibleCells()
        }
    }
    
      
    func startSynOfflineMsg() {
        synManager?.startSys()
    }
    
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let model = messageArray[safe: indexPath.row] {
            if model.cellHeigth > CGFloat(0) {
                return model.cellHeigth
            } else {
                let placecell = cellPlaceHolders[cellIdForMessage(msg:model)]
                if let cell = placecell {
                    cell.reloadData(data: model)
                    let size = cell.systemLayoutSizeFitting(CGSize(width: YYScreenSize().width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
                    model.cellHeigth = size.height
                    return size.height
                }
            }
        }
        return CGFloat.leastNonzeroMagnitude   
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdForMessage(msg:messageArray[safe: indexPath.row]), for: indexPath)
        if let model = messageArray[safe: indexPath.row] {
            cell.reloadData(data: model as Any)
        }
        if let c = cell as? ChatCommonCell, c.delegate == nil {
            c.delegate = self;
            c.selectionStyle = .none
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let model = messageArray[safe: indexPath.row] {
            lastMsgId = model.msgId
            
  
  
  
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChatCommonCell {
            cell.onTapCell()
        }
    }
    
    func cellIdForMessage(msg: CPMessage?) -> String {
        if let message = msg {
            var prefix: String
            var suffix: String
            
            let msgType = message.msgType
            if message.senderPubKey == CPAccountHelper.loginUser()?.publicKey {
                prefix = "Self"
            } else {
                prefix = "Other"
            }
            
            if msgType == .audio {
                suffix = "Audio"
            }
            else if msgType == .text  {
                suffix = "Text"
            }
            else if msgType == .image  {
                suffix = "Image"
            }
            else if msgType == MessageType.groupUpdateNotice {
                suffix = "Text"
            }
            else if msgType.rawValue >= MessageType.groupJoin.rawValue {
                return "SystemMsgCell"
            }
            else {
                suffix = "Unknown"
            }
            return prefix + suffix
        }
          
        return "CellID";
    }
}
