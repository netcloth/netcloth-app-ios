







import UIKit

class ChangePwdController: BaseViewController {

    @IBOutlet weak var passTips: UILabel!
    @IBOutlet weak var privateKeyInput: AutoHeightTextView!
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var repwdInput: UITextField!
    @IBOutlet weak var sureBtn: UIButton!
    
    @IBOutlet weak var pwdEyeBtn: UIButton!
    
    @IBOutlet weak var strengthLabel: UILabel?
    @IBOutlet weak var strengthProgress: UIProgressView?
    @IBOutlet weak var strengthContainer: UIView?

    
    @IBOutlet weak var repwdEyeBtn: UIButton!
    
    var disbag = DisposeBag()
    
    
    var isShowPwd = false {
        didSet {
            passwordInput.isSecureTextEntry = !self.isShowPwd
            let img = self.isShowPwd ? UIImage(named: "open_eye") : UIImage(named: "close")
            self.pwdEyeBtn.setImage(img, for: .normal)
            
        }
    }
    
    
    var ShowRePwd = false {
        didSet {
            repwdInput.isSecureTextEntry = !self.ShowRePwd
            let img = self.ShowRePwd ? UIImage(named: "open_eye") : UIImage(named: "close")
            self.repwdEyeBtn.setImage(img, for: .normal)
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
            
            let len = self.inputLength
            let strlen = "change_input_len".localized().replacingOccurrences(of: "#Len#", with: "\(len)")
        
            self.strengthLabel?.text = t + strlen
            self.strengthLabel?.textColor = c
        }
    }
    
    
    
    var inputLength: Int = 0 {
        didSet {
            let len = self.inputLength
            if len == 0 {
                self.strengthContainer?.isHidden = true
            } else {
                self.strengthContainer?.isHidden = false
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            
        }
        
        super.viewDidLoad()
        configUI()
        configEvent()
        self.inputLength = 0
        self.strength = 0 
    }
    
    func configUI() {
        
        var att1 = NSMutableAttributedString(string: "Export_tip_1".localized(),
                                             attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                                                          NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.gray_90)!])
        
        let att2 = NSMutableAttributedString(string: "Export_tip_2".localized(),
                                             attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13),
                                                          NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.blue)!])
        
        att1.append(att2)
        
        passTips.attributedText = att1
        
        self.sureBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    
    }
    
    func configEvent() {
        
        self.pwdEyeBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isShowPwd = !((self?.isShowPwd)!)
        }).disposed(by: disbag)
        
        self.repwdEyeBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.ShowRePwd = !((self?.ShowRePwd)!)
        }).disposed(by: disbag)
        
        
        passwordInput.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            } else {
            }
            self?.inputLength = self?.passwordInput.text?.count ?? 0
            self?.strength = self?.passwordInput.text?.checkWalletPwdStrength().ruleCount ?? 0
            }.disposed(by: disbag)
        
        
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            let r = (self?.checkInputAvalid())!
            if r.result == false {
                Toast.show(msg: r.msg)
            } else {
                
                let priK = self?.privateKeyInput.text ?? ""
                let pwd = self?.passwordInput.text ?? ""
                
                CPAccountHelper.verifyPrivateKey(priK, callback: { [weak self] (r, msg) in
                    
                    if r == false {
                        self?.showInvalidAlert()
                    }
                    else {
                        CPAccountHelper.changeLoginUser(toPwd: pwd, callback: { [weak self] (r, msg) in
                            if r == false {
                                self?.showInvalidAlert()
                            }
                            else {
                                self?.showValidAlert()
                            }
                        })
                    }
                })
                
            }
        }).disposed(by: disbag)
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard let priK = privateKeyInput.text, priK.count > 0  else {
            return (false,"WalletManager.Error.invalidData".localized());
        }
        
        guard let pwd = passwordInput.text, Config.Account.checkExportPwd(pwd) else {
            return (false,"Export_invalid_pwd".localized());
        }
        if pwd.checkPassthrough().passthrough == false {
            return (false, "Insufficient password strength".localized())
        }
        
        guard let rpwd = repwdInput.text, rpwd == pwd else {
            return (false,"Register_repeat_pwd".localized());
        }
        return (true, "valid data".localized())
    }
    
    func showValidAlert() {
        if let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert {
            alert.titleLabel?.text = "change_valid_title".localized()
            alert.msgLabel?.text = "change_valid_message".localized()
            alert.okButton?.setTitle("change_valid_btn".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func showInvalidAlert() {
        if let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert {
            alert.titleLabel?.text = "change_invalid_title".localized()
            alert.msgLabel?.text = "change_invalid_message".localized()
            alert.okButton?.setTitle("change_invalid_btn".localized(), for: .normal)
            Router.showAlert(view: alert)
        }
    }

}
