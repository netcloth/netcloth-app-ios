







import UIKit


class SessionVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, ChatInterface {
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var sessionQueue : DispatchQueue = OS_dispatch_queue_serial(label: "com.chat.session", qos: .default)
    
    @IBOutlet weak var hubTips: UILabel?
    @IBOutlet weak var msgLabel: UILabel?
    
    @IBOutlet weak var offTipContainer: UIView?
    

    var sessionsArray : [CPSession]?
    let disbag = DisposeBag()
    
    var allUnreadCount: Int = 0 {
        didSet {
            let count = self.allUnreadCount
            if count == 0 {
                self.msgLabel?.text = "Messages".localized()
                self.tabBarItem.badgeValue = nil
            } else {
                self.msgLabel?.text = "Messages".localized() + "(\(count))"
                self.tabBarItem.badgeValue = "\(count)"
                self.tabBarItem.badgeColor = UIColor(hexString: "#FF4141")
            }
        }
    }
    

    
    deinit {
        CPChatHelper.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
        configEvent()
        CPChatHelper.add(self)
    }
    
    var _viewDidAppear = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTable()
        handleConnectChange()
        
        if _viewDidAppear == false {
            IPALManager.shared.onStep1_QueryInfo()
            _viewDidAppear = true
        }
    }
    
    func configUI() {
        
        self.hubTips?.text = "Loading...".localized()
        
        self.tabBarItem.setStyle(imgName: "消息-未选中",
                                 selectedName: "消息-选中",
                                 textColor: UIColor(hexString: "#BFC2CC"),
                                 selectedColor: UIColor(hexString: "#3D7EFF"))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()        
    }
    
    func configEvent() {
        
        self.scanBtn.rx.tap.subscribe(onNext: {
            #if targetEnvironment(simulator)
            Toast.show(msg: "请使用真机测试")
            return
            #endif
            
            Authorize.canOpenCamera(autoAccess: true, result: { (can) in
                if (can) {
                    let vc = WCQRCodeVC()
                    vc.callBack = { [weak vc] (pbkey) in

                        vc?.dismiss(animated: false, completion: nil)
                        
                        let iden = R.className(of: ContactAddVC.self) ?? ""
                        let addVc = R.loadSB(name: "Contact", iden: iden)
                        addVc.vcInitData = pbkey as AnyObject?
                        Router.pushViewController(vc: addVc)
                        
                        withUnsafeMutablePointer(to: &vc!.navigationController!.viewControllers, { (v) in
                            v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
                        })
                    }
                    Router.pushViewController(vc: vc)
                }
                else {
                    Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Device_camera", comment: ""), cancelTitle: nil)
                }
            })
            
        }).disposed(by: disbag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: NSNotification.Name.serviceConnectStatusChange, object: nil)
    }
    
    @IBAction func onTapOffTipContainer() {
        if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
            Router.pushViewController(vc: vc, animate: true, checkSameClass: true)
        }
    }
    
    

    @objc func handleConnectChange() {
        let isClaimOk = IPALManager.shared.store.currentCIpal?.isClaimOk == 1
        let isClaimFail = IPALManager.shared.store.currentCIpal?.isClaimOk == 2
        
        if CPAccountHelper.isConnected() && isClaimOk {
            self.hubTips?.isHidden = true;
            self.offTipContainer?.isHidden = true
        } else {
            self.hubTips?.isHidden = false;
            if CPAccountHelper.isNetworkOk() && !isClaimFail {
                self.hubTips?.text = "connect_ing".localized()
                self.offTipContainer?.isHidden = true
            } else {
                self.hubTips?.text = "connect_fail".localized()
                self.offTipContainer?.isHidden = false
            }
        }
    }
    
    


    func onReceiveMsg(_ msg: CPMessage) {
        if msg.senderPubKey != CPAccountHelper.loginUser()?.publicKey {
            MessageAudioManager.playMessageComing(msg: msg)
        }
        self.reloadTable()
    }
    
    func onCacheMsgRecieve(_ caches: [CPMessage]!) {
        guard !caches.isEmpty else {
            return
        }
        self.reloadTable()
    }
    
    func reloadTable() {
        if Router.currentVC == self {
            CPChatHelper.getAllRecentSessionComplete { [weak self] (ok:Bool, msg, array:[CPSession]?) in
                self?.sessionQueue.async {

                    if let havedarr = self?.sessionsArray, let toinarr = array {
                        for have in havedarr {
                            for toin in toinarr {
                                if have.lastMsgId == toin.lastMsgId {
                                    toin.lastMsg = have.lastMsg
                                    break;
                                }
                            }
                        }
                    }
                    

                    var count = 0
                    if let toinarr = array {
                        for toin in toinarr {
                            count += toin.unreadCount
                            toin.lastMsg?.msgDecodeContent_onlyTextType()
                        }
                    }
                    self?.sessionsArray = array
                    DispatchQueue.main.async {
                        Toast.dismissLoading()
                        self?.allUnreadCount = count
                        self?.tableView.showEmpty(status: ((array?.isEmpty ?? false) ? EmptyStatus.Empty : EmptyStatus.Normal))
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension SessionVC {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        cell.reloadData(data: sessionsArray?[indexPath.row] as Any)
        cell.selectionStyle = .none
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let session = sessionsArray?[indexPath.row] {
            if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC {
                vc.sessionId = Int(session.sessionId)
                vc.toPublicKey = session.relateContact.publicKey
                vc.remark = session.relateContact.remark
                Router.pushViewController(vc: vc)
            }
        }
    }
    
}



extension SessionVC {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        var topDes = "Sticky on top".localized()
        if let session = self.sessionsArray?[indexPath.row] {
            if session.topMark == 1 {
                topDes = "Remove From Top".localized()
            }
        }
        let topOrUn = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: topDes) { [weak self] (action, indexpath) in
            self?.topOrUn(row: indexPath.row)
        }
        

        let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Delete".localized()) { [weak self] (action, indexpath) in
            self?.deleteRow(row: indexPath.row)
        }
        
        return [delete,topOrUn]
    }
    
    func topOrUn(row: Int) {
        if let session = self.sessionsArray?[safe: row] {
            if session.topMark == 1 {

                CPChatHelper.unTop(ofSession: Int(session.sessionId)) { [weak self] (r, msg) in
                    self?.reloadTable()
                }
            }
            else {

                CPChatHelper.markTop(ofSession: Int(session.sessionId)) { [weak self] (r, msg) in
                    self?.reloadTable()
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
                    CPChatHelper.deleteSession(Int(session.sessionId)) { [weak self] (r, msg) in
                        self?.reloadTable()
                    }
                }
            }
        }
    }
}
