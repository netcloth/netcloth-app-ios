//
//  RegisterVC.swift
//  chat
//
//  Created by Grand on 2019/7/24.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class RegisterVC: BaseViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var accountMask: UIView!
    
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var pwdEyeImageV: UIImageView!
    @IBOutlet weak var pwdMask: UIView!
    @IBOutlet weak var pwdEyeBtn: UIButton!
    @IBOutlet weak var strengthLabel: UILabel?
    
    @IBOutlet weak var repwdTF: UITextField!
    @IBOutlet weak var repwdEyeImageV: UIImageView!
    @IBOutlet weak var repwdMask: UIView!
    @IBOutlet weak var repwdEyeBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var registerBtnTop: NSLayoutConstraint!
    
    @IBOutlet weak var serviceBtn: UIButton?
    @IBOutlet weak var privacyBtn: UIButton?
    
    let disbag = DisposeBag()
    
    //MARK:- Getter
    
    /// Must set before strength
    var inputLength: Int = 0 {
        didSet {
            let len = self.inputLength
            if len == 0 {
                self.strengthLabel?.isHidden = true
            } else {
                self.strengthLabel?.isHidden = false
                let strlen = "change_input_len".localized().replacingOccurrences(of: "#Len#", with: "\(len)")
                self.strengthLabel?.text = strlen
            }
        }
    }
    
    /// pwd
    var isShowPwd = false {
        didSet {
            pwdTF.isSecureTextEntry = !self.isShowPwd
            self.pwdEyeImageV.image = self.isShowPwd ? UIImage(named: "open_eye") : UIImage(named: "close")

        }
    }
    
    /// repwd
    var ShowRePwd = false {
        didSet {
            repwdTF.isSecureTextEntry = !self.ShowRePwd
            self.repwdEyeImageV.image = self.ShowRePwd ? UIImage(named: "open_eye") : UIImage(named: "close")
        }
    }
    
    //MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.isHideNavBar = true
        configUI()
        configEvent()
        self.inputLength = 0
    }
    
    func configUI() {
        let sh = YYScreenSize().height
        if sh <= 480 {
            registerBtnTop.constant = 2
        } else if sh <= 568 {
            registerBtnTop.constant = 40
        }
        
        self.registerBtn.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20, opacity: 0.3)
    }
    
    func configEvent() {
        
        ///Secrite
        self.pwdEyeBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isShowPwd = !((self?.isShowPwd)!)
        }).disposed(by: disbag)
        
        self.repwdEyeBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.ShowRePwd = !((self?.ShowRePwd)!)
        }).disposed(by: disbag)
        
        
        ///Input
        accountTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.accountMask.backgroundColor = UIColor(hexString: Color.mask_bottom_fill)
            } else {
                self?.accountMask.backgroundColor = UIColor(hexString: Color.mask_bottom_empty)
            }
            }.disposed(by: disbag)
        
        pwdTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.pwdMask.backgroundColor = UIColor(hexString: Color.mask_bottom_fill)
            } else {
                self?.pwdMask.backgroundColor = UIColor(hexString: Color.mask_bottom_empty)
            }
            self?.inputLength = self?.pwdTF.text?.count ?? 0
            }.disposed(by: disbag)
        
        repwdTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.repwdMask.backgroundColor = UIColor(hexString: Color.mask_bottom_fill)
            } else {
                self?.repwdMask.backgroundColor = UIColor(hexString: Color.mask_bottom_empty)
            }
            }.disposed(by: disbag)
        
        
        /// Register
        self.registerBtn.rx.tap.subscribe(onNext: { [weak self] in
            let r = self?.checkInputAvalid()
            if r?.result == false {
                Toast.show(msg: r?.msg ?? "", position: .center)
            }
            else {
                
                //first show tips
                if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                    //config
                    alert.titleLabel?.text = NSLocalizedString("Register_Warning！", comment: "")
                    alert.msgLabel?.text = NSLocalizedString("Register_W_msg", comment: "")
                    alert.cancelButton?.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
                    alert.okButton?.setTitle(NSLocalizedString("Register_Ok", comment: ""), for: .normal)
                    
                    alert.okBlock = {
                        CPAccountHelper.registerUser(byAccount: (self?.accountTF.text)!, password: (self?.pwdTF.text)!, callback: { (success,msg,user) in
                            if success == true {
                                //success please login
                                self?.saveLastUser(name: user?.accountName)
                                Toast.show(msg: NSLocalizedString("Successful registration", comment: ""), position: .center,onWindow: true)
                                Router.dismissVC()
                            }
                            else {
                                Toast.show(msg: NSLocalizedString("System error", comment: ""))
                            }
                        })
                    }
                    
                    Router.showAlert(view: alert)
                }
            }
        }).disposed(by: disbag)
        
        
        serviceBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let url = URL(string: Config.NetOfficial.ServiceUrl) {
                UIApplication.shared.openURL(url)
            }
        }).disposed(by: disbag)
        
        privacyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let url = URL(string: Config.NetOfficial.PrivacyUrl) {
                UIApplication.shared.openURL(url)
            }
        }).disposed(by: disbag)
    }
    
    func saveLastUser(name: String?) {
        UserDefaults.standard.set(name, forKey: Config.Account.Last_Login_Name)
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard Config.Account.checkAccount(accountTF.text) else {
            return (false,"Register_invalid_account".localized())
        }
        
        guard Config.Account.checkLoginPwd(pwdTF.text)  else {
            return (false,"Register_invalid_pwd".localized());
        }
        
        guard let rpwd = repwdTF.text, let pwd = pwdTF.text, rpwd == pwd else {
            return (false,"Register_repeat_pwd".localized());
        }
        return (true, "valid data".localized())
    }
    
    //MARK:- Segue
    @IBAction func popBack(_ sender: Any) {
        Router.dismissVC()
    }
}
