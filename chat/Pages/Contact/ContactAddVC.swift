  
  
  
  
  
  
  

import UIKit


  
class ContactAddVC: BaseViewController {
    
    @IBOutlet weak var pubkeyLabel: AutoHeightTextView!
    @IBOutlet weak var pbkeyMask: UIView!
    
    @IBOutlet weak var remarkTF: UITextField!
    @IBOutlet weak var remarkMask: UIView!
    
    @IBOutlet weak var addBtn: UIButton!
    
    let disbag = DisposeBag()
    
    var wantAddPublicKey: String?
    var wantRemark: String?
    
      
    
      
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        
        CPContactHelper.getAllContacts { [weak self]  (contacts) in
            self?.contacts = contacts
            self?.checkPubKeyStatus(pbkey: self?.pubkeyLabel.text)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    
      
    var contacts:[CPContact]? = nil
    func checkPubKeyStatus(pbkey: String?) {
        guard let pk = pbkey, let cts = contacts else {
            return
        }
        for ct in cts {
            if ct.publicKey == pk {
                Toast.show(msg: NSLocalizedString("Contact_have_added", comment: ""))
                break
            }
        }
    }
    
    func configUI() {
        
        refreshInput()
        
        self.addBtn.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20, opacity: 0.3)
        
          
        let img = UIImage(named: "扫一扫1")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: img, style: .plain, target: self, action: #selector(onTapScan))
    }
    
    func refreshInput() {
        if let pk = self.wantAddPublicKey {
            pubkeyLabel.text = pk
            remarkTF.text = self.wantRemark
        }
    }
    
    @objc func onTapScan() {
        #if targetEnvironment(simulator)
        Toast.show(msg: "请使用真机测试")
        return
        #endif
        
        Authorize.canOpenCamera(autoAccess: true, result: { (can) in
            if (can) {
                let vc = WCQRCodeVC()
                vc.callBack = { [weak vc, weak self] (output) in
                      
                    if let svc = self {
                        vc?.dismiss(animated: false, completion: nil)
                        let v2 = InnerHelper.v2_decodeScanInput(str: output, wantType: "contact")
                        if v2.valid {
                            let publickey = v2.data as? String  ?? ""
                            if v2.type == SessionType.P2P {
                                  
                                svc.navigationController?.popToViewController(svc, animated: true)
                                svc.wantAddPublicKey = publickey
                                svc.wantRemark = v2.minorData as? String
                                svc.refreshInput()
                                svc.checkPubKeyStatus(pbkey: publickey)
                            }
                            else if v2.type == SessionType.group {
                                svc.navigationController?.popToViewController(svc, animated: false)
                                  
                                if let vc = R.loadSB(name: "GroupInviteDetailVC", iden: "GroupInviteDetailVC") as?  GroupInviteDetailVC {
                                    vc.qr_groupPublickKey = publickey
                                    Router.pushViewController(vc: vc)
                                }
                            }
                        }
                        else {
                            Toast.show(msg: "System error".localized())
                        }
                    }
                }
                Router.pushViewController(vc: vc)
            }
            else {
                Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Device_camera", comment: ""), cancelTitle: nil)
            }
        })
    }
    
    func configEvent() {
    
          
        pubkeyLabel.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.pbkeyMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_fill)
                self?.checkPubKeyStatus(pbkey: e)
            } else {
                self?.pbkeyMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_empty)
            }
            }.disposed(by: disbag)
        
        remarkTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.remarkMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_fill)
            } else {
                self?.remarkMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_empty)
            }
            }.disposed(by: disbag)
        
        
        self.addBtn.rx.tap.subscribe(onNext: { [weak self] in
            
            let r = self?.checkInputAvalid()
            if r?.result == false {
                Toast.show(msg: r!.msg, position: .center)
            }
            else {
                CPContactHelper.addContactUser(self?.pubkeyLabel.text, comment: self?.remarkTF.text, callback: { (success, msg, addedcontact) in
                    Toast.show(msg: msg,position: .center, onWindow: true)
                    if success == false  {
                        return
                    }
                    
                      
                    if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC, let contact = addedcontact {
                        vc.toPublicKey = contact.publicKey
                        vc.remark = contact.remark
                        vc.sessionId = Int(contact.sessionId)
                        
                        Router.pushViewController(vc: vc)
                        
                          
                        if let _ = vc.navigationController {
                            withUnsafeMutablePointer(to: &vc.navigationController!.viewControllers, { (v) in
                                v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
                            })
                        }
                    }
                    else {
                        Router.dismissVC()
                    }
                    
                })
            }
        }).disposed(by: disbag);
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard let account = pubkeyLabel.text, (OC_Chat_Plugin_Bridge.byteLength(ofHex: account) == 65) else {
            return (false,NSLocalizedString("Contact_invalid_address", comment: ""))
        }
        
        guard Config.Account.checkRemarkInput(remark: remarkTF.text) else {
            return (false,NSLocalizedString("Contact_invalid_remark", comment: ""))
        }
        return (true, "有效数据")
    }
}
