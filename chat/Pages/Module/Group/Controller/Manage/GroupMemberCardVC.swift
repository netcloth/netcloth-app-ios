//
//  GroupMemberCardVC.swift
//  chat
//
//  Created by Grand on 2019/12/10.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class GroupMemberCardVC: ContactCardVC {
    @IBOutlet weak var LgroupMasterIden: PaddingLabel?
    
    @IBOutlet weak var sendMsgControl: UIControl?
    @IBOutlet weak var removeMemberControl: UIControl?
    
    @IBOutlet weak var labelGroupNick: UILabel?
    weak var groupStrangeVC: GroupStrangerCardVC?
    
    var groupMember: CPGroupMember?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LgroupMasterIden?.edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        self.LgroupMasterIden?.text = "Founder".localized()
    }
    
    override func configUI() {
        super.configUI()
        
        publicKeyLabel?.edgeInsets = UIEdgeInsets.zero
        publicKeyLabel?.preferredMaxLayoutWidth = YYScreenSize().width - 30*2
        
        sendMsgControl?.backgroundColor = UIColor(hexString: Color.blue)
        sendMsgControl?.setShadow(color: UIColor(hexString: Color.blue)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.2)
        
        removeMemberControl?.backgroundColor = UIColor(hexString: Color.red)
        removeMemberControl?.setShadow(color: UIColor(hexString: Color.red)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.2)
    }
    
    override func configEvent() {
        super.configEvent()
        
        self.roomService?.isMeGroupMaster.subscribe({ [weak self] (e) in
            self?.fillData()
            }).disposed(by: disbag)
        
        //
        self.sendMsgControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onSendMsgToPubkey()
        }).disposed(by: disbag)
        
        self.removeMemberControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onRemoveMember()
        }).disposed(by: disbag)
    }
    
    //MARK:- Action
    func getSessionId() -> Int32? {
        return self.contact?.sessionId
    }
    func getpubkey() -> String? {
        return self.contact?.publicKey
    }
    func getremark() -> String? {
        return self.contact?.remark
    }
    
    //MARK: Tap
    //给成员发消息
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
    
    //MARK: -
    func showDeleteAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                //config
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
            //to detail page
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
        
    //MARK:-
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
            //是我的好友
            self.scrollView?.isHidden = false
            self.strangerContainer?.isHidden = true
            self.fillData()
            
            if let member = groupMember {
                self.labelGroupNick?.text = "Group Alias".localized() + ":" + "\(member.nickName)"
            }
        }
        else if let member =  groupMember {
            //非好友
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
            if self.getpubkey() != CPAccountHelper.loginUser()?.publicKey {
                hide = false
            }
        }
        self.removeMemberControl?.isHidden = hide
        
        //identify
        self.LgroupMasterIden?.isHidden = true
        if let masterPubkey = self.roomService?.groupMasterPubkey,
            getpubkey() == masterPubkey {
            self.LgroupMasterIden?.isHidden = false
        }

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
        
        let color = self.groupMember?.hexPubkey.randomColor() ?? RelateDefaultColor
        smallRemark?.backgroundColor = UIColor(hexString: color)
        
        remark?.text = self.groupMember?.nickName
        if let pubkey = self.groupMember?.hexPubkey {
            publicKeyLabel?.text = "\(pubkey.prefix(10))……\(pubkey.suffix(10))"
        }
        addBlackSwitch?.isOn = false
        
        var hide: Bool = true
        let isMaster = self.roomService?.isMeGroupMaster.value ?? false
        if isMaster == true {
            if self.getpubkey() != CPAccountHelper.loginUser()?.publicKey {
                hide = false
            }
        }
        self.removeMemberControl?.isHidden = hide
        
        //identify
        self.LgroupMasterIden?.isHidden = true
        if let masterPubkey = self.roomService?.groupMasterPubkey,
            getpubkey() == masterPubkey {
            self.LgroupMasterIden?.isHidden = false
        }
    }
    
    //MARK:- Action
    func onAddToContact() {
        if let pubkey = self.getpubkey() , let remark = getremark()  {
            CPContactHelper.addContactUser(pubkey, comment: remark) { (r, msg, contact) in
                Toast.show(msg: msg,position: .center, onWindow: true)
                
                if let pvc = self.parent as? GroupMemberCardVC {
                    pvc.AbstractRequestData()
                }
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
            
            alert.okBlock = { [weak self] in
                CPContactHelper.addContactUser(member.hexPubkey, comment: member.nickName, callback: nil)
                
                InnerHelper.addToBlack(hexPubkey: member.hexPubkey,
                                       target: self?.addBlackSwitch)
            }
            alert.cancelBlock = { [weak self] in
                self?.addBlackSwitch?.isOn = false
            }
        }
    }
    
    override func onActionDeleteFromBlack() {
        if let member = self.groupMember {
            InnerHelper.removeBlack(hexPubkey: member.hexPubkey,
                                    target: self.addBlackSwitch)
        }
    }
    
    override func onSendMsgToPubkey() {
        if let member = self.groupMember {
            CPContactHelper.addContactUser(member.hexPubkey, comment: member.nickName, callback: nil)
            super.onSendMsgToPubkey()
        }
    }
    
    
    //MARK:- Override
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
