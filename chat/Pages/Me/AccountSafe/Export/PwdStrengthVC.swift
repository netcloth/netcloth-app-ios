







import UIKit
import IQKeyboardManagerSwift

enum PageTag: String {
    case exportKeyStore
    case exportPrikey
}


class PwdStrengthVC: BaseViewController {
    
    @IBOutlet weak var inputTipsLabel: UILabel!
    
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var pwdEyeImageV: UIImageView!
    @IBOutlet weak var pwdEyeBtn: UIButton!
    
    @IBOutlet weak var repwdTF: UITextField!
    @IBOutlet weak var repwdEyeImageV: UIImageView!
    @IBOutlet weak var repwdEyeBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var strengthProgress: UIProgressView?
    @IBOutlet weak var strengthLabel: UILabel?
    
    let disbag = DisposeBag()
    var index: Int = 0 
    
    var loginPwd: String?
    var pageTag: PageTag = .exportKeyStore {
        didSet {
            switch self.pageTag {
            case .exportKeyStore:
                self.title = "Account Backup".localized()
            default:
                print("~~")
            }
        }
    }
    
    
    
    
    
    var isShowPwd = false {
        didSet {
            pwdTF.isSecureTextEntry = !self.isShowPwd
            self.pwdEyeImageV.image = self.isShowPwd ? UIImage(named: "open_eye") : UIImage(named: "close")
            
        }
    }
    
    
    var ShowRePwd = false {
        didSet {
            repwdTF.isSecureTextEntry = !self.ShowRePwd
            self.repwdEyeImageV.image = self.ShowRePwd ? UIImage(named: "open_eye") : UIImage(named: "close")
        }
    }
    
    
    var strength: Int = 0 {
        didSet {
            var p:Float = 0.25
            var c = UIColor(hexString: "#E20533")
            var t = "Weaker".localized()
            if self.strength == 2 {
                p = 0.5
                t = "Weak".localized()
            }
            else if self.strength == 3 {
                p = 0.75
                t = "Strong".localized()
                c = UIColor(hexString: "#F5A623")
            }
            else if self.strength == 4 {
                p = 1
                t = "Stronger".localized()
                c = UIColor(hexString: "#5BB80E")
            }
            
            self.strengthProgress?.progress = p
            self.strengthProgress?.progressTintColor = c
            self.strengthProgress?.trackTintColor = UIColor(hexString: "#EDEFF2")
            self.strengthLabel?.text = t
            self.strengthLabel?.textColor = c
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        configUI()
        configEvent()
        self.strength = 0
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: "#F7F8FA")

        var att1 = NSMutableAttributedString(string: "Export_tip_1".localized(),
                                             attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                                                          NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.gray_90)!])
        
        let att2 = NSMutableAttributedString(string: "Export_tip_2".localized(),
                                             attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                                                          NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.blue)!])
        
        att1.append(att2)
        
        inputTipsLabel.attributedText = att1
        
        self.registerBtn.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20, opacity: 0.3)
    }
    
    func configEvent() {
        
        
        self.pwdEyeBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isShowPwd = !((self?.isShowPwd)!)
        }).disposed(by: disbag)
        
        self.repwdEyeBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.ShowRePwd = !((self?.ShowRePwd)!)
        }).disposed(by: disbag)
        
        
        
        pwdTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            }
            self?.strength = self?.pwdTF.text?.checkWalletPwdStrength().ruleCount ?? 0
            
            }.disposed(by: disbag)
        
        repwdTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            }
            }.disposed(by: disbag)
        
        
        
        self.registerBtn.rx.tap.subscribe(onNext: { [weak self] in
            let r = self?.checkInputAvalid()
            if r?.result == false {
                Toast.show(msg: r?.msg ?? "", position: .center)
            }
            else {
                self?.toExportDetail(pwd: self?.pwdTF.text)
            }
        }).disposed(by: disbag)
    }
    
    
    func toExportDetail(pwd: String?) {
        if let p = pwd, let old = loginPwd {
            
            CPAccountHelper.exportKeystoreAndPrivateKey(old, exportPassword: p) { [weak self] (r, msg, keystore, prikey) in
                if r == false {
                    Toast.show(msg: msg)
                } else {
                    if let vc = R.loadSB(name: "Export", iden: "ExportDetailVC") as? ExportDetailVC {
                        vc.keyStore = keystore
                        vc.privateKey = prikey
                        vc.index = self?.index ?? 0
                        Router.pushViewController(vc: vc)
                    }
                }
            }
        }
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard let pwd = pwdTF.text, Config.Account.checkExportPwd(pwd) else {
            return (false,"Export_invalid_pwd".localized());
        }
        if pwd.checkPassthrough().passthrough == false {
            return (false, "Insufficient password strength".localized())
        }
        
        guard let rpwd = repwdTF.text, rpwd == pwd else {
            return (false,"Register_repeat_pwd".localized());
        }
        return (true, "valid data".localized())
    }

}

