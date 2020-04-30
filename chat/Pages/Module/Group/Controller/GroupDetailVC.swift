







import UIKit


class GroupDetailVC: BaseTableViewController {
    
    @IBOutlet weak var Vheader: NVGroupMemberSummary?
    @IBOutlet weak var LGroupName: UILabel?
    @IBOutlet weak var LGroupNotice: UILabel?
    
    
    
    @IBOutlet weak var cellGroupName: NCConfigCell?
    @IBOutlet weak var cellGroupQrCode: NCConfigCell?
    @IBOutlet weak var cellGroupNotice: NCConfigCell?
    
    @IBOutlet weak var cellManagerGroup: UITableViewCell?
    
    @IBOutlet weak var cellMyAlias: UITableViewCell?
    @IBOutlet weak var LMyAlias: UILabel?
    
    @IBOutlet weak var cellDeleteChatHistory: SystemCell?
    @IBOutlet weak var cellDeleteandLeave: UITableViewCell?
    
    @IBOutlet weak var cellRecieveNotify: UITableViewCell?
    @IBOutlet weak var LRecieveNotify: UILabel?
    
    @IBOutlet weak var markTopSwitch: UISwitch?

    
    let disbag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.tableView.adjustFooter()
        fillInfo()
        markTopSwitch?.onTintColor = UIColor(hexString: Color.blue)
        markTopSwitch?.tintColor = UIColor(hexString: "#E1E4E9")
    }
    
    func configEvent() {
        
        self.Vheader?.didRefreshContent = { [weak self] in
            self?.refreshHeaderHeight()
        }
        self.Vheader?.configEvent()
        
        self.roomService?.isMeGroupMaster.distinctUntilChanged().map({ (isMaster) -> Bool in
            return !isMaster
        }).bind(to: (cellGroupName?.rightOption)!.rx.isHidden).disposed(by: disbag)
        
        self.roomService?.isMeGroupMaster.distinctUntilChanged().map({ (isMaster) -> Bool in
            return !isMaster
        }).bind(to: (cellGroupNotice?.rightOption)!.rx.isHidden).disposed(by: disbag)
        
        self.roomService?.isMeGroupMaster.distinctUntilChanged().subscribe(onNext: { [weak self] (e) in
            self?.tableView?.reloadData()
        }).disposed(by: disbag)
        
        self.tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexpath) in
            let cell = self?.tableView.cellForRow(at: indexpath)
            if cell == self?.cellGroupName {
                self?.onTapSetName()
            } else if cell == self?.cellGroupNotice {
                self?.onTapSetNotice()
            } else if cell == self?.cellManagerGroup {
                self?.onTapManagerGroup()
            }
            else if cell == self?.cellMyAlias {
                self?.onTapEditMyAlias()
            }
            else if cell == self?.cellDeleteChatHistory {
                self?.onTapDeleteChats()
            }
            else if cell == self?.cellDeleteandLeave {
                self?.onTapLeaveGroup()
            }
            else if cell == self?.cellRecieveNotify {
                self?.onTapGroupRecieveStyle()
            }
            else if cell == self?.cellGroupQrCode {
                self?.onTapGroupQrCode()
            }
            
        }).disposed(by: disbag)
        
        self.roomService?.chatContact?.observable.subscribe({ [weak self] (event) in
            self?.fillInfo()
        }).disposed(by: disbag)
        
        self.roomService?.myGroupAlias.subscribe({ [weak self] (event) in
            self?.fillInfo()
        }).disposed(by: disbag)
        
        
        
        
        markTopSwitch?.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] (event) in
            let sessionId = Int(self?.roomService?.relateSession?.sessionId ?? 0)
            if self?.markTopSwitch?.isOn == true {
                CPSessionHelper.markTop(ofSession: sessionId, complete: nil)
            } else {
                CPSessionHelper.unTop(ofSession: sessionId, complete: nil)
            }
        }).disposed(by: disbag)
    }
    
    func refreshHeaderHeight() {
        self.Vheader?.height = (self.Vheader?.viewHeight() ?? 0)
    }
    
    func fillInfo() {
        let contact = self.roomService?.chatContact?.value
        let groupName = contact?.remark
        let notice = contact?.decodeNotice()
        
        self.LGroupName?.text = groupName
        self.LGroupNotice?.text = notice
        self.LMyAlias?.text = self.roomService?.myGroupAlias.value
        
        #if DEBUG
        self.LGroupName?.text = "pub:\(contact!.publicKey.suffix(4))"
        #endif
        
        markTopSwitch?.isOn = (self.roomService?.relateSession?.topMark == 1)
        self.LRecieveNotify?.text = (contact?.isDoNotDisturb == true)
            ? "Mute Notifications".localized()
            :  "Receive Notifications".localized()
    }
    
    
    func onTapSetName() {
        guard self.roomService?.isMeGroupMaster.value == true else {
            return
        }
        
        if let vc = R.loadSB(name: "GroupSetNameVC", iden: "GroupSetNameVC") as? GroupSetNameVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    func onTapSetNotice() {
        if let vc = R.loadSB(name: "GroupSetNoticeVC", iden: "GroupSetNoticeVC") as? GroupSetNoticeVC {   
            Router.pushViewController(vc: vc)
        }
    }
    
    
    func onTapManagerGroup() {
        guard self.roomService?.isMeGroupMaster.value == true else {
            return
        }
        if let vc = R.loadSB(name: "GroupManageVC", iden: "GroupManageVC") as? GroupManageVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    func onTapEditMyAlias() {
        if let vc = R.loadSB(name: "GroupSetMineNickNameVC", iden: "GroupSetMineNickNameVC") as? GroupSetMineNickNameVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    
    func onTapDeleteChats() {
        _ = showDeleteChatAlert().subscribe(onNext: { [weak self] (e) in
            
            let sessionId = Int(self?.roomService?.chatContact?.value.sessionId ?? 0)
            let pubkey = self?.roomService?.chatContact?.value.publicKey ?? ""
            
            CPSessionHelper.clearSessionChats(in: sessionId, with: SessionType.group, complete: {(r, msg) in
                if r == true {
                    self?.navigationController?.popViewController(animated: true)
                    
                    NotificationCenter.post(name: .chatRecordDeletes, object: pubkey)
                    
                } else {
                    Toast.show(msg: "System error".localized())
                }
            })
        })
    }
    
    func onTapGroupQrCode() {
        if let vc = R.loadSB(name: "GroupQrCodeVC", iden: "GroupQrCodeVC") as? GroupQrCodeVC {
            vc.groupContact = self.roomService?.chatContact?.value
            Router.pushViewController(vc: vc)
        }
    }
    
   
    func onTapLeaveGroup() {
        _ = showLeaveChatAlert().subscribe(onNext: { [weak self] (e) in
            let sessionId = Int(self?.roomService?.chatContact?.value.sessionId ?? 0)
            let pubkey = self?.roomService?.chatContact?.value.publicKey ?? ""
            guard let prikey = self?.roomService?.chatContact?.value.decodePrivateKey() else {
                return
            }
            self?.showLoading()
            CPGroupChatHelper.sendGroupQuit(inGroupPrivateKey: prikey) { (response) in
                self?.dismissLoading()
                let json = JSON(response)
                if json["code"].int != ChatErrorCode.OK.rawValue {
                    Toast.show(msg: "System error".localized())
                } else {
                    CPContactHelper.deleteContactUser(pubkey, callback: { (r, msg) in
                        self?.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }
        })
    }
    
    
    func onTapGroupRecieveStyle() {
        _ = showRecieveNoticeAlert().subscribe(onNext: { [weak self] (v) in
            let pubkey = (self?.roomService?.chatContact?.value.publicKey ?? "")
            if v == 1 {
                
                InnerHelper.removeMute(hexPubkey: pubkey,
                                       chatType: NCProtoChatType.chatTypeGroup,
                                       target: self?.cellRecieveNotify,
                                       complete: { (r) in
                                        if r {
                                            self?.roomService?.chatContact?.change(commit: { (ct) in
                                                ct.isDoNotDisturb = false
                                            })
                                        }
                })
            }
            else if v == 2 {
                
                InnerHelper.addToMute(hexPubkey: pubkey,
                                      chatType: NCProtoChatType.chatTypeGroup,
                                      target: self?.cellRecieveNotify,
                                      complete: { (r) in
                                        if r {
                                            self?.roomService?.chatContact?.change(commit: { (ct) in
                                                ct.isDoNotDisturb = true
                                            })
                                        }
                })
            }
        })
    }
    
    
    func showRecieveNoticeAlert() -> Observable<Int> {
        return Observable.create { [weak self] (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "GroupNoticeAlert") as? GroupNoticeAlert {
                
                let rec = !(self?.roomService?.chatContact?.value.isDoNotDisturb == true)
                alert.hightlightRecieve(isRec: rec)
                
                alert.muteHandle = {
                    observer.onNext(2)
                }
                
                alert.recieveHandle = {
                    observer.onNext(1)
                }
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }
    
    
    func showLeaveChatAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                
                alert.titleLabel?.isHidden = true
                alert.msgLabel?.text = "Group_Chat_Leave_Tip".localized()
                alert.msgLabel?.textColor = UIColor(hexString: Color.black)
                
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Confirm".localized(), for: .normal)
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onNext(())
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }
    
    func showDeleteChatAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                
                alert.titleLabel?.isHidden = true
                alert.msgLabel?.text = "Group_Chat_Dele_Tip".localized()
                alert.msgLabel?.textColor = UIColor(hexString: Color.black)
                
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Confirm".localized(), for: .normal)
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onNext(())
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }

    
    
    
}


extension GroupDetailVC {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 30
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = self.view.backgroundColor
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        let isMaster  = self.roomService?.isMeGroupMaster.value ?? false
        if isMaster == true {
            if cell == self.cellDeleteandLeave {
                return CGFloat.leastNonzeroMagnitude
            }
            else if cell == self.cellDeleteChatHistory {
                if let c = cell as? SystemCell {
                    c.showLastSeparator(false)
                }
            }
        }
        else {
            if cell == self.cellManagerGroup {
                return CGFloat.leastNonzeroMagnitude
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
        
    }
    
    
}
