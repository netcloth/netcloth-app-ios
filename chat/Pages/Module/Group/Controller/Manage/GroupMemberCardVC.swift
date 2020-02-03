  
  
  
  
  
  
  

import UIKit

class GroupMemberCardVC: ContactCardVC {
    
    @IBOutlet weak var sendMsgControl: UIControl?
    @IBOutlet weak var removeMemberControl: UIControl?
    @IBOutlet weak var labelGroupNick: UILabel?
    weak var groupStrangeVC: GroupStrangerCardVC?
    
      
      
    
      
  
    
    var groupMember: CPGroupMember?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configEvent() {
        super.configEvent()
        
        self.roomService?.isMeGroupMaster.subscribe({ [weak self] (e) in
            self?.fillData()
            }).disposed(by: disbag)
        
          
        self.sendMsgControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onSendMsgToPubkey()
        }).disposed(by: disbag)
        
        self.removeMemberControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onRemoveMember()
        }).disposed(by: disbag)
    }
    
      
    func getSessionId() -> Int32? {
        return self.contact?.sessionId
    }
    func getpubkey() -> String? {
        return self.contact?.publicKey
    }
    func getremark() -> String? {
        return self.contact?.remark
    }
    
      
      
    func onSendMsgToPubkey() {
        guard let sessionId = self.getSessionId(),
            let pubkey = self.getpubkey() else {
                return
        }
        let remark = self.getremark()
        Router.dismissVC(animate: false, completion: {
            if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC {
                vc.sessionId = Int(sessionId)
                vc.toPublicKey = pubkey
                vc.remark = remark
                Router.pushViewController(vc: vc)
            }
        }, toRoot: true)
    }
    
      
    func onRemoveMember() {
        guard let pubkey = getpubkey() else {
            return
        }
        
        _ = showDeleteAlert().subscribe(onNext: { [weak self] (e) in
            
            let pubkeys = [pubkey]
            guard let prikey = self?.roomService?.chatContact?.value.decodePrivateKey() else {
                return
            }
            
            if let alert = R.loadNib(name: "WaitAlert") as? WaitAlert {
                Router.showAlert(view: alert)
            }
            self?.showLoading()
            CPGroupChatHelper.sendGroupKickReq(pubkeys, inGroupPrivateKey: prikey) { (response) in
                self?.dismissLoading()
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
    
      
    func showDeleteAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                  
                alert.titleLabel?.text = "Confirm".localized()
                alert.msgLabel?.text = "Group_Dele_Member_Msg".localized()
                
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
        
      
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupStrangerCardVC {
            self.groupStrangeVC = vc
            vc.sourceTag = self.sourceTag
        }
    }
    
    override func AbstractRequestData() {
        guard let pubkey = self.contactPublicKey,
            let sessionId = self.roomService?.chatContact?.value.sessionId
            else {
                fatalError("must be set contactPublicKey")
        }
        CPContactHelper.getOneContact(byPubkey: pubkey) { [weak self] (r, msg, tmpContact) in
            if tmpContact?.status != ContactStatus.strange {
                self?.contact = tmpContact
            }
            self?.AbstractHandleData()
        }
        
        CPGroupManagerHelper.getOneGroupMember(pubkey, inSession: Int(sessionId)) { [weak self] (r, msg, member) in
            self?.groupMember = member
            self?.AbstractHandleData()
        }
    }
    
    override func AbstractHandleData() {
        
        if let ct = contact {
              
            self.scrollView?.isHidden = false
            self.strangerContainer?.isHidden = true
            self.fillData()
            
            if let member = groupMember {
                self.labelGroupNick?.text = "Group Alias".localized() + ":" + "\(member.nickName)"
            }
        }
        else if let member =  groupMember {
              
            self.groupStrangeVC?.groupMember =  member
            self.groupStrangeVC?.sourceTag = self.sourceTag
            self.groupStrangeVC?.fillData()
            
            self.strangerContainer?.isHidden = false
            self.scrollView?.isHidden = true
        }
        else {
            self.scrollView?.isHidden = true;
            self.strangerContainer?.isHidden = true;
        }
    }
    
    override func fillData() {
        super.fillData()
        
        var hide: Bool = true
        let isMaster = self.roomService?.isMeGroupMaster.value ?? false
        if isMaster == true {
            if self.getpubkey() == CPAccountHelper.loginUser()?.publicKey {
            }
            else {
                hide = false
            }
        } else {
            
        }
        
        self.removeMemberControl?.isHidden = hide
        
    }

}


class GroupStrangerCardVC : GroupMemberCardVC {
    
    @IBOutlet weak var addToNewFriend: UIControl?
    
    override func configEvent() {
        super.configEvent()
        addToNewFriend?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onAddToContact()
        }).disposed(by: disbag)
        
        
    }
    
    override func fillData() {
        smallRemark?.text = self.groupMember?.nickName.getSmallRemark()
        remark?.text = self.groupMember?.nickName
        if let pubkey = self.groupMember?.hexPubkey {
            publicKeyLabel?.text = "\(pubkey.prefix(10))……\(pubkey.suffix(10))"
        }
        addBlackSwitch?.isOn = false
        
        var hide: Bool = true
        let isMaster = self.roomService?.isMeGroupMaster.value ?? false
        if isMaster == true {
            if self.getpubkey() == CPAccountHelper.loginUser()?.publicKey {
            }
            else {
                hide = false
            }
        } else {
            
        }
        
        self.removeMemberControl?.isHidden = hide
    }
    
      
    func onAddToContact() {
        if let pubkey = self.getpubkey() , let remark = getremark()  {
            CPContactHelper.addContactUser(pubkey, comment: remark) { (r, msg, contact) in
                Toast.show(msg: msg,position: .center, onWindow: true)
            }
        }
    }
    
      
    override func onActionAddBlack() {
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView,
            let member = self.groupMember {
            alert.titleLabel?.text = "Blacklist".localized()
            let msg = "Blacklist_msg".localized().replacingOccurrences(of: "#remark#", with: member.nickName)
            alert.msgLabel?.text = msg
            
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = {
                CPContactHelper.addContactUser(member.hexPubkey, comment: member.nickName, callback: nil)
                CPContactHelper.addUser(toBlacklist: member.hexPubkey) { [weak self] (r, msg) in
                    if r == false {
                        Toast.show(msg: msg)
                        self?.addBlackSwitch?.isOn = false
                    }
                }
            }
            alert.cancelBlock = { [weak self] in
                self?.addBlackSwitch?.isOn = false
            }
        }
    }
    
    override func onActionDeleteFromBlack() {
        if let member = self.groupMember {
            CPContactHelper.removeUser(fromBlacklist: member.hexPubkey) { (r, msg) in
                if r == false {
                    Toast.show(msg: msg)
                }
            }
        }
    }
    
      
    override func onSendMsgToPubkey() {
        if let member = self.groupMember {
            CPContactHelper.addContactUser(member.hexPubkey, comment: member.nickName, callback: nil)
            super.onSendMsgToPubkey()
        }
    }
    
    
      
    override func getSessionId() -> Int32? {
        return self.groupMember?.sessionId
    }
    override func getpubkey() -> String? {
        return self.groupMember?.hexPubkey
    }
    override func getremark() -> String? {
        return self.groupMember?.nickName
    }
    override func AbstractRequestData() {
    }
    
}
