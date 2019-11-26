







import UIKit

class ContactCardVC: BaseViewController {
    
    private var contact: CPContact?
    var contactPublicKey: String?
    

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
    
    let disbag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    func fetchData() {
        if let pk = self.contactPublicKey {
            CPContactHelper.getOneContact(byPubkey: pk) { [weak self] (r, msg, tmpContact) in
                self?.contact = tmpContact
                self?.fillData()
            }
        }
    }
    
    func fillData() {
        if let ct = contact {
            smallRemark?.text = ct.remark.getSmallRemark()
            remark?.text = ct.remark
            nickremark?.text = "Contact_Alias".localized() + ": " + ct.remark;
            
            publicKeyLabel?.text = ct.publicKey
            
            addBlackSwitch?.isOn =  ct.isBlack
        }
    }
    

    func configUI() {
        publicKeyLabel?.edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        publicKeyLabel?.preferredMaxLayoutWidth = YYScreenSize().width - 27*2
        
        addBlackSwitch?.onTintColor = UIColor(hexString: "#3D7EFF")
        addBlackSwitch?.tintColor = UIColor(hexString: "#E1E4E9")
    }
    
    func configEvent() {
        

        qrcodeBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onActionShowQR()
        }).disposed(by: disbag)
        

        sendMsgBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onActionSend()
        }).disposed(by: disbag)
        

        changeRemark?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onActionRemark()
        }).disposed(by: disbag)
        

        deleteContact?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onActionDeleteContact()
        }).disposed(by: disbag)
        
        

        addBlackSwitch?.rx.value.subscribe(onNext: { [weak self] (isOn) in
            if isOn {
                self?.onActionAddBlack()
            } else {
                self?.onActionDeleteFromBlack()
            }
        }).disposed(by: disbag)
        
    }
    
    

    func onActionShowQR() {
        if let ct = self.contact {
            if let json = InnerHelper.toString(contact: ct) {
                QrCodeVC.generateQRCode(data: json) { (img) in
                    if img != nil {
                        let qr = QRPhotoImgView(image: img)
                        Router.showAlert(view: qr)
                    }
                }
            }
        }
    }
    
    func onActionSend() {
        if self.sourceTag == 1 {
            Router.dismissVC()
        } else {
            
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
    
    func onActionAddBlack() {
        
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView,
            let contact = self.contact {
            alert.titleLabel?.text = "Blacklist".localized()
            let msg = "Blacklist_msg".localized().replacingOccurrences(of: "#remark#", with: contact.remark)
            alert.msgLabel?.text = msg
            
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = {
                CPContactHelper.addUser(toBlacklist: contact.publicKey) { [weak self] (r, msg) in
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
    
    func onActionDeleteFromBlack() {
        if let contact = self.contact {
            CPContactHelper.removeUser(fromBlacklist: contact.publicKey) { (r, msg) in
                if r == false {
                    Toast.show(msg: msg)
                }
            }
        }
    }
}
