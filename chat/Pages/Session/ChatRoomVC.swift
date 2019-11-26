







import UIKit
import IQKeyboardManagerSwift



class ChatRoomVC:BaseViewController,
    UITableViewDelegate, UITableViewDataSource,
    ChatInterface,
    KeyboardManagerDelegate,
    ChatCommonCellDelegate,
    SDPhotoBrowserDelegate
{
    
    var sessionId: Int? {
        didSet {
            RoomStatus.sessionId = self.sessionId
        }
    }
    var toPublicKey: String? {
        didSet {
            RoomStatus.toPublicKey = self.toPublicKey
            CPChatHelper.setRoomToPubkey(self.toPublicKey)
        }
    }
    var remark: String? {
        didSet {
            RoomStatus.remark = self.remark
        }
    }

    @IBOutlet weak var toolbarBottomToSafe: NSLayoutConstraint!
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: ChatToolBar!
    
    @IBOutlet weak var notFoundTipContainer: UIView?
    
    var messgeArray: [CPMessage] = []
    

    private var lastMsgId: CLongLong = 1
    
    let disbag = DisposeBag()
    
    var obv1: NSObjectProtocol?
    var obv2: NSObjectProtocol?
    
    var msgPatchQueue : DispatchQueue = OS_dispatch_queue_serial(label: "com.chat.room.msg", qos: .default)
    

    
    deinit {
        RoomStatus.toPublicKey = nil
        CPChatHelper.setRoomToPubkey(nil)
        
        IQKeyboardManager.shared.disabledToolbarClasses.removeLast()
        NotificationCenter.default.removeObserver(obv1)
        NotificationCenter.default.removeObserver(obv2)
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        SRRecordingAudioPlayerManager.shared()?.stop()
        CPChatHelper.remove(self)
        
        
    }
    
    var cellPlaceHolders: [String: ChatCommonCell] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)]
        

        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses.append(type(of: self))
        
        KeyboardManager.shared.setObserver(self)
        
        messgeArray = []
        configUI()
        configEvent()
        Toast.showLoading()
        fetchDataMsg(createtime: -1, msgId: -1)
        
        CPChatHelper.add(self)
        calculateCells()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.showBlackLine()
        RoomStatus.inChatRoom = true
        judgeIsBlackList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CPChatHelper.setAllReadOfSession(sessionId ?? 0, complete: nil)
        RoomStatus.inChatRoom = false
    }
    
    func calculateCells() {
        let suppert = ["OtherUnknown","SelfUnknown",
                       "OtherText","SelfText",
                       "OtherAudio","SelfAudio",
                       "SelfImage","OtherImage"]
        
        var cell: ChatCommonCell?
        for iden in suppert {
            cell = self.tableView.dequeueReusableCell(withIdentifier: iden) as? ChatCommonCell
            cell?.width = YYScreenSize().width
            cellPlaceHolders[iden] = cell
        }
    }
    

    
    func configUI() {
        
        self.title = remark
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
        
        obv1 =
        NotificationCenter.default.addObserver(forName: UIMenuController.didHideMenuNotification, object: nil, queue: OperationQueue.main) { [weak self] (notice) in
            self?.notInMenu = true
        }
        
        obv2 =
            NotificationCenter.default.addObserver(forName: NoticeNameKey.contactRemarkChange.noticeName, object: nil, queue: OperationQueue.main) { [weak self] (notice) in
                
                if let contact = notice.object as? CPContact {
                    self?.onHandleRemarkChange(contact: contact)
                }
        }
    }
    
    func judgeIsBlackList() {
        if let pubkey = self.toPublicKey {
            CPContactHelper.getOneContact(byPubkey: pubkey) { [weak self] (r, msg, contact) in
                if contact?.isBlack == true {
                    self?.view.endEditing(true)
                    self?.toolBar.resetInBlack(isBlack: true)
                } else {
                    self?.toolBar.resetInBlack(isBlack: false)
                }
            }
        }
    }
    

    
    @objc func loadHistroy() {
        if  let msg = messgeArray.first {
            fetchDataMsg(createtime: msg.createTime, msgId: msg.msgId)
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func fetchDataMsg(createtime: Double ,msgId: CLongLong) {
        

        CPChatHelper.getMessagesInSession(sessionId ?? 0, createTime: createtime, fromMsgId: msgId, size: 17) {
            [weak self] (ok, msg, array: [CPMessage]?) in
            
            self?.msgPatchQueue.async {
                

                if let toarray = array {
                    for to in toarray {
                        to.msgDecodeContent()
                    }
                }
                
                DispatchQueue.main.async {
                    Toast.dismissLoading()
                    self?.refreshControl.endRefreshing()
                    
                    self?._onHandleMsgsData(array ?? [], complete: {

                        if msgId == -1 || createtime == -1 {
                            self?._refreshToBottom()
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
    

    @objc func _refreshVisibleCells() {
        self.msgPatchQueue.async {
            self.reloadData()
        }
    }
    
    func _refreshToBottom(animate:Bool = false) {
        self.reloadData()
        DispatchQueue.main.async {
            if (self.tableView.contentSize.height - self.tableView.bounds.size.height) > 0 {
                self.tableView.scrollToBottom(animated: animate)
            }
        }
    }
    
    func _refreshToTop() {
        let tmpId = lastMsgId
        self.reloadData()
        var toRow = 0
        for (index , item) in self.messgeArray.enumerated() {
            if item.msgId == tmpId {
                toRow = index
                break
            }
        }
        DispatchQueue.main.async {
            self.tableView.isHidden = true
            self.tableView.scrollToRow(at: IndexPath(row: toRow, section: 0), at: .bottom, animated: false)
            self.tableView.isHidden = false
        }
    }
    
    fileprivate func reloadData() {
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

            if self?.toPublicKey == contact.publicKey {
                self?.remark = contact.remark
                DispatchQueue.main.async {
                    self?.title = self?.remark
                }
            }

            self?.messgeArray.forEach({ (msg) in
                if msg.senderPubKey == contact.publicKey {
                    msg.senderRemark = contact.remark
                }
            })
            self?._refreshVisibleCells()
        }
    }

    

    private var menuOpItem: CPMessage?
    private var menuController: UIMenuController?
    private var notInMenu: Bool = true
    
    func checkShouldToBottom() -> Bool {
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
                    guard let idx = self?.messgeArray.firstIndex(of: msg) else { return }
                                  self?.messgeArray.remove(at: idx)
                                  self?.reloadData()
                                  
                                  CPChatHelper.deleteMessage(msg.msgId, complete: nil)
                }
            }
        }
        
    }
    
    func showMenuAtCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        
        if menuController == nil {
            menuController = UIMenuController.shared
            menuController?.arrowDirection = .default
        }
        
        guard let msg = self.messgeArray[safe: indexPath.row] else { return }
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
            for msg in self.messgeArray.reversed() {
                if msg.msgId == msgTmp.msgId {
                    msg.toServerState = msgTmp.toServerState
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

            if self?.checkShouldToBottom() == true {
                self?._refreshToBottom(animate: true)
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
            

            accept.forEach { (msg) in
                msg.msgDecodeContent()
            }
            

            self?._orderMsgs(inArray: &accept)
            

            var last:CPMessage? = nil;
            for tmp in accept {
                if last == nil {
                    if isOnline {
                        let diff = tmp.createTime - (self?.messgeArray.last?.createTime ?? 0)
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
        if msg.senderPubKey == CPAccountHelper.loginUser()?.publicKey {
        } else if (msg.senderPubKey == self.toPublicKey) {
        }
        else {
            return false
        }
        return true
    }
    
    func _deleteRepeatInDataArray(wantInArray: [CPMessage]) -> [CPMessage] {
        var toInsertA: [CPMessage] = []
        for toIn in wantInArray {
            var toAdd: Bool = true
            for haved in messgeArray {
                if toIn.signHash == haved.signHash {
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
            if (m1.createTime < m2.createTime) && (m1.msgId < m2.msgId) {
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
            messgeArray.append(contentsOf: msg)
        } else {
            messgeArray.insert(contentsOf: msg, at: 0)
        }
        

        _orderMsgs(inArray: &messgeArray)
    }
    
    

    func onTapAvatar(pubkey: String) {
        
        if pubkey == support_account_pubkey {
            return
        }
        
        if let vc = R.loadSB(name: "ContactCard", iden: "ContactCardVC") as? ContactCardVC {
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
                CPChatHelper.retrySendMsg(msgId)
            }
            Router.showAlert(view: alert)
        }
    }
    
    var toShowImage: UIImage?
    func onShowBigPhoto(_ img: UIImage, containerView: UIView) {
        toShowImage = img
        let pb = SDPhotoBrowser()
        pb.imageCount = 1
        pb.sourceImagesContainerView = containerView
        if let cell = containerView as? ImageChatCell {
            pb.sourceImgView = cell.pictureImage
        }
        
        pb.delegate = self
        pb.show()
    }
    
    func photoBrowser(_ browser: SDPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        return toShowImage ?? UIImage()
    }
    


    func sendMsg(text: String) {
        CPChatHelper.sendText(text, toUser: toPublicKey!)
    }
    
    func sendAudio(data: Data) {
        CPChatHelper.sendAudioData(data , toUser: toPublicKey!)
    }
    
    func sendImage(data: Data) {
        CPChatHelper.sendImageData(data, toUser: toPublicKey!)
    }
    

    func onKeyboardFrame(_ toframe: CGRect, dura: Double, aniCurve: Int) {
        print(toframe)
        if toframe.origin.y >= YYScreenSize().height {
            onKbHidden(dura: dura, aniCurve: aniCurve)
        }
        else {
            onKbTop(Y: toframe.origin.y, kbH: toframe.size.height, dura: dura, aniCurve: aniCurve)
        }
    }
    
    func onKbHidden(dura: Double, aniCurve: Int) {
        self.view.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: dura, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(aniCurve)), animations: {
            [weak self] in
            self?.toolbarBottomToSafe.constant = 0
            self?.view.layoutIfNeeded()
            self?.reloadData()
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

extension ChatRoomVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messgeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let model = messgeArray[safe: indexPath.row] {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdForMessage(msg:messgeArray[safe: indexPath.row]), for: indexPath)
        if let model = messgeArray[safe: indexPath.row] {
            cell.reloadData(data: model as Any)
        }
        if let c = cell as? ChatCommonCell, c.delegate == nil {
            c.delegate = self;
            c.selectionStyle = .none
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let model = messgeArray[safe: indexPath.row] {
            lastMsgId = model.msgId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChatCommonCell {
            cell.playAudio()
        }
    }
    
    func cellIdForMessage(msg: CPMessage?) -> String {
        if let message = msg {
            var prefix: String
            var suffix: String
            if message.senderPubKey == CPAccountHelper.loginUser()?.publicKey {
                prefix = "Self"
            } else {
                prefix = "Other"
            }
            if message.msgType == .audio {
                suffix = "Audio"
            }
            else if message.msgType == .text  {
                suffix = "Text"
            }
            else if message.msgType == .image  {
                suffix = "Image"
            }
            else {
                suffix = "Unknown"
            }
            return prefix + suffix            
        }

        return "CellID";
    }
}

var key_height = "key_Height"
var key_isAudioPlaying = "key_playing"
extension CPMessage  {
    var cellHeigth: CGFloat {
        set {
            objc_setAssociatedObject(self, &key_height, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_height) as? CGFloat {
                return n
            }
            return 0
        }
    }
    
    var isAudioPlaying: Bool {
        set {
            objc_setAssociatedObject(self, &key_isAudioPlaying, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_isAudioPlaying) as? Bool {
                return n
            }
            return false
        }
    }
}
