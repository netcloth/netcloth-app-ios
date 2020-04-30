







import UIKit
import PromiseKit


class SessionVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, ChatDelegate {
    
    @IBOutlet weak var searchBtn: UIButton?
    @IBOutlet weak var searchControl: UIControl?
    
    @IBOutlet weak var tableView: UITableView!
    var sessionQueue : DispatchQueue = OS_dispatch_queue_serial(label: "com.chat.session", qos: .default)
    
    @IBOutlet weak var msgLabel: UILabel?
    
    
    
    @IBOutlet weak var hubTips: UILabel?
    
    
    @IBOutlet weak var offTipContainer: UIView?
    @IBOutlet weak var offlineTipLabel: UILabel?
    
    
    var sessionsArray : [CPSession]?
    
    var allUnreadCount: Int = 0 {
        didSet {
            let count = self.allUnreadCount
            if count == 0 {
                self.msgLabel?.text = "Messages".localized()
                self.tabBarItem.badgeValue = nil
            } else {
                self.msgLabel?.text = "Messages".localized() + "(\(count))"
                self.tabBarItem.badgeValue = "\(count)"
                self.tabBarItem.badgeColor = UIColor(hexString: Color.red)
            }
            setDesktopIconBadge(number: count)
        }
    }
    
    func setDesktopIconBadge(number: Int) {
        DispatchQueue.main.async {
            ExtensionShare.unreadStore.setUnreadCount(number)
            PPNotificationCenter.shared.reCalBadge()
        }
    }
    
    var notifyPreview: CPGroupNotifyPreview?
    
    let disbag = DisposeBag()
    
    
    deinit {
        CPChatHelper.removeInterface(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
        configEvent()
        CPChatHelper.addInterface(self)
        showLoading()
        Config.Older_Had_Tip = true
    }
    
    var _viewDidAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        _handleConnectChange(getRecommend: false)
        reloadGroupNotify()
        onRecommendedReload()
        
        if _viewDidAppear == false {
            IPALManager.shared.onStep1_QueryInfo()
            _viewDidAppear = true
        }
    }
    
    func configUI() {
        
        self.hubTips?.text = "Loading...".localized()
        
        self.tabBarItem.setStyle(imgName: "消息-未选中",
                                 selectedName: "消息-选中",
                                 textColor: UIColor(hexString: Color.gray),
                                 selectedColor: UIColor(hexString: Color.black))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        
        
        offlineTipLabel?.textColor = UIColor(hexString: Color.red)
    }
    
    func configEvent() {
        
        searchControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            ContactGroupSearchHelper.onTapSearch()
        }).disposed(by: disbag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: NSNotification.Name.serviceConnectStatusChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_onActionUnreadChange), name: NoticeNameKey.chatRoomUnreadStatusChange.noticeName, object: nil)
    }
    
    @objc func _onActionUnreadChange() {
        self._reloadTableView(onlyCount: true)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @objc func handleConnectChange() {
        _handleConnectChange()
    }
    fileprivate func _handleConnectChange(getRecommend:Bool = true) {
        let isClaimOk = IPALManager.shared.store.currentCIpal?.isClaimOk == 1
        let isClaimFail = IPALManager.shared.store.currentCIpal?.isClaimOk == 2
        let isSeedError = IPALManager.shared.store.isSeedError == true
        
        if CPAccountHelper.isConnected() && isClaimOk {
            self.hubTips?.isHidden = true
            self.offTipContainer?.isHidden = true
            if getRecommend {
                
                if !(GlobalStatusStore.shared.recommendedGroup?.isEmpty == false) {
                    GlobalStatusStore.shared.onRequestRecommendedGroup {
                                       self.reloadTable()
                                   }
                }
                
                
                if GlobalStatusStore.shared.curAssist == nil {
                    GlobalStatusStore.shared.requestServerAssist {
                        self.reloadTable()
                    }
                }
            }
        }
        else {
            self.hubTips?.isHidden = false
            if isSeedError {
                self.hubTips?.text = "connect_fail".localized()
                self.offTipContainer?.isHidden = false
                self.offlineTipLabel?.text = "Seed_error_tip".localized()
            }
            else {
                if CPAccountHelper.isNetworkOk() && !isClaimFail {
                    self.hubTips?.text = "connect_ing".localized()
                    self.offTipContainer?.isHidden = true
                }
                else {
                    self.hubTips?.text = "connect_fail".localized()
                    self.offTipContainer?.isHidden = false
                    self.offlineTipLabel?.text = "Network_error_tip".localized()
                }
            }
        }
    }
    
    @IBAction func onTapOffTipContainer() {
        
        let isSeedError = IPALManager.shared.store.isSeedError == true
        if isSeedError {
            MeVC.onLogout()
        }
        else {
            if let vc = R.loadSB(name: "IPALList", iden: "IPAListVC") as? IPAListVC {
                vc.fromSource = .C_IPAL
                Router.pushViewController(vc: vc)
            }
        }
    }
    
    
    
    func onReceiveMsg(_ msg: CPMessage) {
        
        self.reloadTable()
        
        if msg.senderPubKey == CPAccountHelper.loginUser()?.publicKey {
        } else if msg.doNotDisturb == true {
        } else {
            
            MessageNotifyManager.playMessageComing(msg: msg)
        }
    }
    
    func onCacheMsgRecieve(_ caches: [CPMessage]!) {
        guard !caches.isEmpty else {
            return
        }
        self.reloadTable()
    }
    
    
    func onReceiveGroupChatMsgs(_ msgs: [CPMessage]) {
        self.reloadTable()
    }
    
    
    func onUnreadRsp(_ response: [CPUnreadResponse]!) {
        self.sessionQueue.async {
            
            if let havedarr = self.sessionsArray, let toinarr = response {
                for toin in toinarr {
                    for have in havedarr {
                        if have.relateContact.publicKey == toin.groupHexPubkey &&
                            have.relateContact.sessionType == SessionType.group {
                            have.groupUnreadCount = toin.unreadCount
                            let sessionId = have.relateContact.sessionId
                            CPSessionHelper.setUnReadCount(toin.unreadCount, ofSession: Int(sessionId), with: SessionType.group, complete: nil)
                            break;
                        }
                    }
                }
            }
        }
        self.reloadTable()
    }
    
    func onReceive(_ notice: CPGroupNotify?) {
        reloadGroupNotify()
    }
    
    func onSessionNeedChange(_ change: Any!) {
        self.reloadTable()
    }
    
    func onLogonNotify(_ notify: NCProtoNetMsg!) {
        
        if let alert = R.loadNib(name: "OneButtonOneMsgAlert") as? OneButtonOneMsgAlert {
            var tips = "Logon_Notice".localized()
            
            let diff =  Double(notify.head.msgTime) / 1000.0
            let date = NSDate(timeIntervalSince1970: TimeInterval(diff))
            let dateStr = date.string(withFormat: "HH:mm") ?? ""
            tips = tips.replacingOccurrences(of: "#mark#", with: dateStr)
            
            if let logon = try? NCProtoLogonNotify.parse(from: notify.data_p) {
                let device = logon.deviceType
                var str: String = ""
                if device == NCProtoDeviceType.deviceTypeIos {
                    str = "iOS".localized()
                } else if device == NCProtoDeviceType.deviceTypeAndroid {
                    str = "Android".localized()
                }
                else if device == NCProtoDeviceType.deviceTypePc {
                    str = "PC".localized()
                }
                tips = tips.replacingOccurrences(of: "#device#", with: str)
            }
            
            
            
            alert.msgLabel?.text = tips
            alert.msgLabel?.textColor = UIColor(hexString: Color.black)
            alert.msgLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
            
            alert.okButton?.setTitle("clear_alert_btn_text".localized(), for: .normal)
            
            Router.showAlert(view: alert)
        }
    }
    
    
    
    
    
    func reloadTable() {
        if checkCanReload() == false {
            return
        }
        _reloadTableView(onlyCount: false)
    }
    
    fileprivate func onRecommendedReload() {
        GlobalStatusStore.shared.recommendedGroupSession = nil
        GlobalStatusStore.shared.getRecommendedSession().done { (result) in
            GlobalStatusStore.shared.recommendedGroupSession = result
        }.catch { (error) in
        }.finally {
            self.reloadTable()
        }
    }
    
    
    
    fileprivate func _reloadTableView(onlyCount: Bool) {
        CPSessionHelper.getAllRecentSessionComplete { [weak self] (ok:Bool, msg, array:[CPSession]?) in
            self?.sessionQueue.async {
                if onlyCount == false {
                    
                    if let havedarr = self?.sessionsArray, let toinarr = array {
                        for have in havedarr {
                            for toin in toinarr {
                                if have.sessionType == toin.sessionType &&
                                    have.lastMsgId == toin.lastMsgId &&
                                    have.lastMsg?.msgId == toin.lastMsg?.msgId {
                                    toin.lastMsg = have.lastMsg
                                    break;
                                }
                            }
                        }
                    }
                }
                
                
                
                var strangeArray = array?.filter({ (session) -> Bool in
                    if session.relateContact.status == .strange {
                        return true
                    }
                    
                    if session.relateContact.status == .assistHelper {
                        if let _ = session.relateContact.publicKey.isCurNodeAssist() {
                            
                        } else {
                            return true
                        }
                    }
                    
                    
                    return false
                })
                let strangeFirst = strangeArray?[safe: 0]
                
                var finaArray = array
                var fakeStranger: FakeStrangerSession? = nil
                if array?.isEmpty == false && strangeFirst != nil {
                    finaArray = array?.filter({ (session) -> Bool in
                        if strangeArray?.contains(session) == true {
                            return false
                        }
                        return true
                    })
                    fakeStranger = FakeStrangerSession()
                }
                
                
                
                var count = 0
                if let toinarr = finaArray {
                    for toin in toinarr {
                        if toin.relateContact.isDoNotDisturb == false {
                            count += toin.unreadCount
                        }
                    }
                }
                
                
                var strangerCount = 0
                if strangeArray?.isEmpty == false {
                    if let sa = strangeArray {
                        for item in sa {
                            if item.unreadCount > 0 {
                                strangerCount += 1
                            }
                        }
                    }
                    count += (strangerCount)
                }
                
                
                if fakeStranger != nil {
                    fakeStranger!.updateTime = strangeFirst?.updateTime ?? 0
                    fakeStranger!.unreadCount = strangerCount
                    fakeStranger!.topMark = strangeFirst?.topMark ?? 0
                    fakeStranger!.lastMsg = strangeFirst?.lastMsg
                    
                    finaArray?.insert(fakeStranger!, at: 0)
                }
                
                
                
                if let notify = self?.notifyPreview, notify.needApproveCount > 0 {
                    count += notify.unreadCount
                    let fakeNotify = FakeNotifySession()
                    fakeNotify.unreadCount = notify.unreadCount
                    fakeNotify.updateTime = notify.lastNotice?.createTime ?? 0
                    finaArray?.insert(fakeNotify, at: 0)
                }
                
                
                if let rs = GlobalStatusStore.shared.recommendedGroupSession,
                    let rg = GlobalStatusStore.shared.recommendedGroup
                {
                    let unreadCount = rs.groupUnreadCount
                    count += unreadCount
                    let fakeSession = FakeRecommendedSession()
                    fakeSession.unreadCount = unreadCount
                    
                    let ctime = rg.first?.create_time.utcTimeIntervalSince1970() ?? 0
                    fakeSession.updateTime = ctime
                    fakeSession.topMark = rs.topMark
                    fakeSession.sessionId = rs.sessionId
                    finaArray?.insert(fakeSession, at: 0)
                }
                
                let sortDescriptors = [
                    NSSortDescriptor(key: "topMark", ascending: false),
                    NSSortDescriptor(key: "updateTime", ascending: false)]
                
                if onlyCount {
                    self?.setDesktopIconBadge(number: count)
                }
                else {
                    finaArray = (finaArray as NSArray?)?.sortedArray(using: sortDescriptors) as? [CPSession]
                    self?.sessionsArray = finaArray
                    DispatchQueue.main.async {
                        self?.dismissLoading()
                        self?.allUnreadCount = count
                        self?.tableView.showEmpty(status: ((finaArray?.isEmpty ?? false) ? EmptyStatus.Empty : EmptyStatus.Normal))
                        self?.tableView.reloadData()
                        self?.tableView.emptyView()?.tapBtn?.removeAllBlocks(for: .touchUpInside)
                        self?.tableView.emptyView()?.tapBtn?.addBlock(for: .touchUpInside, block: { (btn) in
                            self?.toMyQrcode()
                        })
                    }
                }
            }
        }
    }
    
    @objc fileprivate func toMyQrcode() {
        let vc = R.loadSB(name: "QrCode", iden: "QrCodeVC")
        Router.pushViewController(vc: vc)
    }
    
    
    func reloadGroupNotify() {
        if checkCanReload() == false {
            return
        }
        CPGroupManagerHelper.getGroupNotifyPreviewSessionCallback {[weak self] (r, msg, notify) in
            self?.notifyPreview = notify
            self?.reloadTable()
        }
        
    }
    
}

extension SessionVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = sessionsArray?[indexPath.row] as Any
        
        var cellId = "SessionCell"
        if data is FakeStrangerSession {
            cellId = "PatchSessionCell"
        } else if data is FakeNotifySession {
            cellId = "FakeNotifyCell"
        } else if data is FakeRecommendedSession {
            cellId = "FakeRecommendCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.reloadData(data: data)
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let session = sessionsArray?[indexPath.row] else {
            return
        }
        if session is FakeStrangerSession {
            toStrangerVC()
        }
        else if session is FakeNotifySession {
            toNotifyPreviewVC()
        }
        else if session is FakeRecommendedSession {
            toGroupRecommendation()
        }
        else {
            if session.sessionType == .P2P {
                toP2PChat(bySession: session)
            }
            else if session.sessionType == .group {
                toGroupChat(bySession: session)
            }
        }
    }
    
    
    
    fileprivate func toNotifyPreviewVC() {
        if let vc = R.loadSB(name: "GroupNotifySessionVC", iden: "GroupNotifySessionVC") as? GroupNotifySessionVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    func toStrangerVC() {
        
        if let vc = R.loadSB(name: "StrangerMessages", iden: "StrangerSessionListVC") as? StrangerSessionListVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    
    func toP2PChat(bySession session: CPSession) {
        if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC {
            vc.sessionId = Int(session.sessionId)
            vc.toPublicKey = session.relateContact.publicKey
            vc.remark = session.relateContact.remark
            Router.pushViewController(vc: vc)
        }
    }
    
    func toGroupChat(bySession session: CPSession) {
        let contact = session.relateContact
        if  session.sessionId > 0,
            contact.decodePrivateKey().count > 10 {
            
            if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
                vc.chatContact = contact
                Router.pushViewController(vc: vc)
            }
        }
        else {
            Toast.show(msg: "System error".localized())
        }
    }
    
    func toGroupRecommendation() {
        if let vc = R.loadSB(name: "RecommendedGroupListVC", iden: "RecommendedGroupListVC") as? RecommendedGroupListVC {
            vc.recommendGroups = GlobalStatusStore.shared.recommendedGroup 
            Router.pushViewController(vc: vc)
        }
    }
    
}



extension SessionVC {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let data = sessionsArray?[safe: indexPath.row]
        
        if (data is FakeStrangerSession ||
            data is FakeNotifySession) {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let session = self.sessionsArray?[indexPath.row] else {
            return nil
        }
        
        var topDes = "Sticky on top".localized()
        if session.topMark == 1 {
            topDes = "Remove From Top".localized()
        }
        let topOrUn = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: topDes) { [weak self] (action, indexpath) in
            self?.topOrUn(row: indexPath.row)
        }
        
        
        if session is FakeRecommendedSession {
            return [topOrUn]
        }
        else {
            let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Delete".localized()) { [weak self] (action, indexpath) in
                self?.deleteRow(row: indexPath.row)
            }
            return [delete,topOrUn]
        }
    }
    
    func topOrUn(row: Int) {
        if let session = self.sessionsArray?[safe: row] {
            
            let reload = {
                if session is FakeRecommendedSession {
                    self.onRecommendedReload()
                } else {
                    self.reloadTable()
                }
            }
            
            if session.topMark == 1 {
                
                CPSessionHelper.unTop(ofSession: Int(session.sessionId)) { [weak self] (r, msg) in
                    reload()
                }
            }
            else {
                
                CPSessionHelper.markTop(ofSession: Int(session.sessionId)) { [weak self] (r, msg) in
                    reload()
                }
            }
        }
    }
    
    
    func deleteRow(row: Int) {
        if let session = self.sessionsArray?[safe: row] {
            
            
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                
                alert.titleLabel?.text = NSLocalizedString("Session_W_Title", comment: "")
                alert.msgLabel?.text = NSLocalizedString("Session_W_Msg", comment: "")
                alert.cancelButton?.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
                alert.okButton?.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
                Router.showAlert(view: alert)
                
                alert.okBlock = {
                    CPSessionHelper.deleteSession(Int(session.sessionId)) { [weak self] (r, msg) in
                        self?.reloadTable()
                    }
                }
            }
        }
    }
}
