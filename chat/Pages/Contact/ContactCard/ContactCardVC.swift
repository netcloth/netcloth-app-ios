//
//  ContactCardVC.swift
//  chat
//
//  Created by Grand on 2019/9/24.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class ContactCardVC: BaseViewController {
    
    var contact: CPContact?
    var contactPublicKey: String?
    
    //1 from chat,
    var sourceTag: Int? = 0
    
    @IBOutlet weak var smallRemark: UILabel?
    @IBOutlet weak var remark: UILabel?
    @IBOutlet weak var nickremark: UILabel?
    
    @IBOutlet weak var qrcodeBtn: UIButton?
    @IBOutlet weak var publicKeyLabel: PaddingLabel?
    
    @IBOutlet weak var changeRemark: UIControl?
    @IBOutlet weak var deleteContact: UIControl?
    @IBOutlet weak var addBlackSwitch: UISwitch?
    
    @IBOutlet weak var sendMsgBtn: UIButton?
    
    @IBOutlet weak var scrollView: UIScrollView?
    
    @IBOutlet weak var strangerContainer: UIView?
    weak var strangerContactVC: StrangerCardVC?
    
    @IBOutlet weak var topMaskView: UIView?
    
    
    let disbag = DisposeBag()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AbstractRequestData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StrangerCardVC {
            self.strangerContactVC = vc
            vc.sourceTag = self.sourceTag
        }
    }
    
    
    func AbstractRequestData() {
        guard let pk = self.contactPublicKey else {
            fatalError("must be set contactPublicKey")
        }
        CPContactHelper.getOneContact(byPubkey: pk) { [weak self] (r, msg, tmpContact) in
            self?.contact = tmpContact
            self?.AbstractHandleData()
        }
    }
    
    func AbstractHandleData() {
        guard let ct = contact  else {
            self.strangerContainer?.isHidden = true;
            return
        }
        if ct.status == .strange {
            self.strangerContactVC?.contact = ct
            self.strangerContactVC?.sourceTag = self.sourceTag
            self.strangerContactVC?.fillData()
            self.strangerContainer?.isHidden = false
            self.scrollView?.isHidden = true
        } else {
            self.scrollView?.isHidden = false
            self.strangerContainer?.isHidden = true
            self.fillData()
        }
    }
    
    func fillData() {
        guard let ct = contact  else {
            return
        }
        smallRemark?.text = ct.remark.getSmallRemark()
        remark?.text = ct.remark
        let color = ct.publicKey.randomColor()
        smallRemark?.backgroundColor = UIColor(hexString: color)
        
        nickremark?.text = "Contact_Alias".localized() + ": " + ct.remark;
        publicKeyLabel?.text = ct.publicKey
        addBlackSwitch?.isOn =  ct.isBlack
    }
    
    //MARK:- Config
    func configUI() {
        
        publicKeyLabel?.edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        publicKeyLabel?.preferredMaxLayoutWidth = YYScreenSize().width - 27*2
        
        addBlackSwitch?.onTintColor = UIColor(hexString: Color.blue)
        addBlackSwitch?.tintColor = UIColor(hexString: "#E1E4E9")
        
        scrollView?.adjustOffset()
        
        sendMsgBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
        let colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor(rgb: 0xffffff, alpha: 0).cgColor]
        topMaskView?.fakeGradientLayer(colors)
    }
    
    func configEvent() {
        
        //show qr
        qrcodeBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onActionShowQR()
        }).disposed(by: disbag)
        
        //send
        sendMsgBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onActionSend()
        }).disposed(by: disbag)
        
        //change remark
        changeRemark?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onActionRemark()
        }).disposed(by: disbag)
        
        //delete contact
        deleteContact?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onActionDeleteContact()
        }).disposed(by: disbag)
        
        
        //add black
        addBlackSwitch?.rx.value.subscribe(onNext: { [weak self] (isOn) in
            if isOn {
                self?.onActionAddBlack()
            } else {
                self?.onActionDeleteFromBlack()
            }
        }).disposed(by: disbag)
        
    }
    
    
    //MARK:- Action
    func onActionShowQR() {
        if let ct = self.contact {
            if let json = InnerHelper.v2_toString(contact: ct) {
                
                _ = QrCodeVC.v2_createShareAppImage(withContact: ct)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { (image) in
                    if let img = image {
                        let qr = QRPhotoImgView(image: img)
                        qr.contentMode = .scaleAspectFill
                        Router.showAlert(view: qr)
                    }
                })
            }
        }
    }
    
    func onActionSend() {
        if self.sourceTag == 1 {
            if let vcs = self.navigationController?.viewControllers {
                for v in vcs {
                    if v is ChatRoomVC {
                        self.navigationController?.popToViewController(v, animated: true)
                        break
                    }
                }
            }
        }
        else {
            if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC, let ct = self.contact {
                vc.sessionId = Int(ct.sessionId)
                vc.toPublicKey = ct.publicKey
                vc.remark = ct.remark
                Router.pushViewController(vc: vc)
            }
        }
    }
    
    func onActionRemark() {
        if let vc = R.loadSB(name: "ContactCard", iden: "RemarkNameVC") as? RemarkNameVC,
            let contact = self.contact {
            vc.contact = contact
            Router.pushViewController(vc: vc)
        }
    }
    
    func onActionDeleteContact() {
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView,
            let contact = self.contact {
            alert.titleLabel?.text = "Contact_W_Title".localized()
            let msg = "Contact_W_msg".localized().replacingOccurrences(of: "#remark#", with: contact.remark)
            alert.msgLabel?.text = msg
            
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = {
                CPContactHelper.deleteContactUser(contact.publicKey, callback: { (r, msg) in
                    Router.dismissVC(animate: true, completion: nil, toRoot: true)
                })
            }
        }
    }
    //MARK:- 黑名单
    func onActionAddBlack() {
        
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView,
            let contact = self.contact {
            alert.titleLabel?.text = "Blacklist".localized()
            let msg = "Blacklist_msg".localized().replacingOccurrences(of: "#remark#", with: contact.remark)
            alert.msgLabel?.text = msg
            
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = { [weak self]  in
                InnerHelper.addToBlack(hexPubkey: contact.publicKey, target: self?.addBlackSwitch)
            }
            alert.cancelBlock = { [weak self] in
                self?.addBlackSwitch?.isOn = false
            }
        }
    }
    
    func onActionDeleteFromBlack() {
        if let contact = self.contact {
            InnerHelper.removeBlack(hexPubkey: contact.publicKey,
                                    target: self.addBlackSwitch)
        }
    }
}

//MARK:- Stranger
class StrangerCardVC: ContactCardVC {
    @IBOutlet weak var addToNewFriend: UIControl?
    
    override func AbstractRequestData() {
    }
    
    override func configEvent() {
        super.configEvent()
        addToNewFriend?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onAcitonAddNewFriends()
        }).disposed(by: disbag)
    }
    
    func onAcitonAddNewFriends() {
        if let contact = self.contact {
            self.showLoading()
            CPContactHelper.update(.newFriend, whereContactUser: contact.publicKey) { (r, msg) in
                self.dismissLoading()
                if r == false {
                    Toast.show(msg: msg)
                } else {
                    //delete StrangerSessionListVC
                    if let toVcs = self.navigationController?.viewControllers.filter({ (vc) -> Bool in
                        if vc is StrangerSessionListVC {
                            return false
                        }
                        return true
                    }) {
                        self.navigationController?.viewControllers = toVcs
                    }
                    NotificationCenter.post(name: NoticeNameKey.newFriendsCountChange)
                    
                    //fake store
                    let msg = CPMessage()
                    msg.senderPubKey = CPAccountHelper.loginUser()?.publicKey ?? ""
                    msg.toPubkey = contact.publicKey
                    msg.msgType = .welcomNewFriends
                    msg.msgData = "Welcom_tip".localized().data(using: String.Encoding.utf8)
                    
                    msg.signHash = OC_Chat_Plugin_Bridge.getRandomSign()
                    
                    CPChatHelper.fakeSendMsg(msg, complete: nil)
                    
                    //dismiss
                    Router.dismissVC()
                    
                }
            }
        }
    }
}
