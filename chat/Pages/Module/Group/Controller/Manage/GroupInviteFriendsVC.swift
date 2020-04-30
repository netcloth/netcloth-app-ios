







import UIKit

class GroupInviteFriendsVC: GroupSelectContactVC {
    
    var pageTag: Int = 0
    
    fileprivate var groupMembers: Set<String>?
    override func viewDidLoad() {
        prepareMembers()
        super.viewDidLoad()
        configTitle()
    }
    
    func configTitle() {
        if pageTag == 0 {
            self.title = "Add Group Members".localized()
        } else if pageTag == 1 {
            self.title = "Remove Members".localized()
        }
    }
    
    func prepareMembers() {
        if let array =  self.roomService?.groupAllMember?.map({ member in member.hexPubkey }) {
            groupMembers = Set(array)
        }
    }
    
    override func reloadData() {
        if pageTag == 0 {
            self.filterInvitee()
        } else if pageTag == 1 {
            self.filterDelete()
        }
    }
    
    func filterDelete() {
        
        let owerPubkey = self.roomService?.groupMasterPubkey ?? ""
        let selfpubkey = CPAccountHelper.loginUser()?.publicKey
        
        let sessionId = self.roomService?.chatContact?.value.sessionId ?? 0
        CPGroupManagerHelper.getAllMemberList(inGroupSession: Int(sessionId)) { [weak self] (r, msg, list) in
            
            var contacts:[CPContact] = []
            let _ = list?.filter({ (member) -> Bool in
                if member.hexPubkey == owerPubkey ||
                member.hexPubkey == selfpubkey {
                    return false
                }
                
                let ct = CPContact()
                ct.publicKey = member.hexPubkey
                ct.sessionId = member.sessionId
                ct.remark = member.nickName
                contacts.append(ct)
                
                return true
            })
            
            self?.fillData(contacts: contacts)
        }
    }
    
    
    func filterInvitee() {
        CPContactHelper.getNormalContacts { [weak self]  (contacts) in
            let selfpubkey = CPAccountHelper.loginUser()?.publicKey
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.status == .assistHelper ||
                    ct.status == .strange {
                    return false
                }
                if self?.pageTag == 1 , ct.publicKey == selfpubkey  {
                    return false
                }
                return true
            }
            
            let contacts: [CPContact]? = filter
            self?.fillData(contacts: contacts)
        }
    }
    
    
    
    
    
    override func onTapDone() {
        guard let node =  IPALManager.shared.store.currentCIpal else {
            Toast.show(msg: "Please select C-IPAL first".localized())
            return
        }
        
        var array: [String] = [] 
        if let sindexs =  self.tableView?.indexPathsForSelectedRows {
            for indexPath in sindexs {
                let key = indexArray[indexPath.section]
                if let model = self.models[key]?[indexPath.row] {
                    array.append(model.publicKey)
                }
            }
        }
        if pageTag == 0 {
            invitePeoples(array: array)
        }
        else if pageTag == 1 {
            delPeoples(array: array)
        }
    }
    
    func invitePeoples(array: [String]?) {
        let groupname = self.roomService?.chatContact?.value.remark ?? ""
        let prikey = self.roomService?.chatContact?.value.decodePrivateKey() ?? Data()
        
        let grouppubkey = OC_Chat_Plugin_Bridge.hexPublicKey(fromPrivatekey: prikey)
        let gpubdata = OC_Chat_Plugin_Bridge.data(fromHexString: grouppubkey)
        
        if let pubkeys = array {
            for hexpubkey in pubkeys {
                let inviteType = self.roomService?.chatContact?.value.inviteType
                if inviteType == CPGroupInviteType.needApprove.rawValue  {
                    var pk = arc4random()
                    let pkD = Data(bytes: &pk, count: MemoryLayout.size(ofValue: pk))
                    CPGroupChatHelper.sendGroupInvite(groupname, groupPrivateKey: pkD, groupPubKey: gpubdata, toInviteeUser: hexpubkey)
                } else {
                    CPGroupChatHelper.sendGroupInvite(groupname, groupPrivateKey: prikey, groupPubKey: gpubdata, toInviteeUser: hexpubkey)
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
        
        if let rootVC = Router.rootVC as? UINavigationController,
            let baseTabVC = rootVC.topViewController as? GrandTabBarVC {
            baseTabVC.switchToTab(index: 0)
        }
    }
    
    func delPeoples(array: [String]?) {
        
        guard let prikey = self.roomService?.chatContact?.value.decodePrivateKey(),
            let pubkeys = array, pubkeys.count > 0 else {
                return
        }
        
        _ = showDeleteAlert(count: pubkeys.count).subscribe(onNext: { [weak self] (e) in
            if let alert = R.loadNib(name: "WaitAlert") as? WaitAlert {
                Router.showAlert(view: alert)
            }
            
            CPGroupChatHelper.sendGroupKickReq(pubkeys, inGroupPrivateKey: prikey) { (response) in
                Router.dismissVC(animate: false) {
                    let json = JSON(response)
                    if json["code"].int == ChatErrorCode.OK.rawValue ||
                        json["code"].int == ChatErrorCode.partialOK.rawValue {
                        self?.showSuccessDeleteAlert()
                    } else {
                        Toast.show(msg: "System error".localized())
                    }
                }
            }
        })
    }
    
    func showSuccessDeleteAlert() {
        guard let successV = R.loadNib(name: "UploadResultAlert") as? UploadResultAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        successV.imageView?.image = UIImage(named: "backup_result_success")
        successV.msgLabel?.text = "Group_Member_Kick_Succ".localized()
        successV.okButton?.setTitle("OK".localized(), for: .normal)
        Router.showAlert(view: successV)
        successV.okBlock = { [weak self] in
            
            if let vcs = self?.navigationController?.viewControllers {
                for v in vcs {
                    if v is GroupDetailVC {
                        self?.navigationController?.popToViewController(v, animated: true)
                        break
                    }
                }
            }
        }
    }
    

    func showDeleteAlert(count: Int) -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                
                alert.titleLabel?.isHidden = true
                var tip = "Group_Member_Kick_Tip".localized()
                tip = tip.replacingOccurrences(of: "#mark#", with: "\(count)")
                alert.msgLabel?.text = tip
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
    
    
    
    
    
    override func lastChanceChange(cell: UITableViewCell, model: CPContact?) {
        if pageTag == 0 {
            let member = model?.publicKey ?? ""
            if groupMembers?.contains(member) == true {
                cell.contentView.alpha = 0.6
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
            } else {
                cell.contentView.alpha = 1
                cell.selectionStyle = .default
                cell.isUserInteractionEnabled = true
            }
        }
    }
    
}
