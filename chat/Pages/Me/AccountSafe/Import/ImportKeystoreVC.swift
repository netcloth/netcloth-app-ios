//
//  ImportKeystoreVC.swift
//  chat
//
//  Created by Grand on 2019/9/12.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class ImportKeystoreVC: BaseViewController {
    
    @IBOutlet weak var keystoreInput: AutoHeightTextView!
    @IBOutlet weak var accountInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var adjustLabel: UILabel!
    
    var disbag = DisposeBag()

    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: "#F7F8FA")
        self.adjustLabel.adjustsFontSizeToFitWidth = true
        
        self.sureBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        ///Input
        accountInput.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            } else {
            }
            }.disposed(by: disbag)
        
        passwordInput.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            } else {
            }
            }.disposed(by: disbag)
        
        // import
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            let r = (self?.checkInputAvalid())!
            if r.result == false {
                Toast.show(msg: r.msg)
            } else {
                let ks = self?.keystoreInput.text ?? ""
                let account = self?.accountInput.text ?? ""
                let pwd = self?.passwordInput.text ?? ""
                
                CPAccountHelper.importKeystore(ks, accountName: account, password: pwd, callback: { [weak self] (r, msg, user) in
                    if r == false {
                        if msg == "Account is existed".localized() {
                            Toast.show(msg: msg)
                        } else {
                            self?.showInvalidAlert()
                        }
                    }
                    else {
                        let sourckey = UserSettings.sourceKey(BackupKey.accountBackup.rawValue, ofUser: Int(user.userId))
                        UserSettings.setObject("1", forSourceKey: sourckey)
                        self?.showValidAlert(user, pwd: pwd, account: account)
                    }
                })
            }
        }).disposed(by: disbag)
    }
    
    
    
    
    //MARK:- Helper
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard let ks = keystoreInput.text, ks.count > 0  else {
            return (false,"WalletManager.Error.invalidData".localized());
        }
        
        guard Config.Account.checkAccount(accountInput.text)  else {
            return (false,"Register_invalid_account".localized());
        }
        
        guard Config.Account.checkExportPwd(passwordInput.text) else {
            return (false,"Export_invalid_pwd".localized());
        }
        
        return (true, "valid data".localized())
    }
    
    func showValidAlert(_ register:User, pwd: String, account: String) {
        if let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert {
            alert.titleLabel?.text = "import_valid_title".localized()
            alert.msgLabel?.text = "import_valid_message".localized()
            alert.okButton?.setTitle("import_valid_btn".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = { [weak self] in
                CPAccountHelper.login(withUid: Int(register.userId), password: pwd,callback: { (success, msg) in
                    if success == false {
                        let t = msg ?? "login_wrong_pwd".localized()
                        Toast.show(msg: t, position: .center)
                    } else {
                        UserDefaults.standard.set(account, forKey: Config.Account.Last_Login_Name)
                        NotificationCenter.post(name: .loginStateChange)
                    }
                })
            }
        }
    }
    
    func showInvalidAlert() {
        if let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert {
            alert.titleLabel?.text = "import_invalid_title".localized()
            alert.msgLabel?.text = "import_invalid_message".localized()
            alert.okButton?.setTitle("import_invalid_btn".localized(), for: .normal)
            Router.showAlert(view: alert)
        }
    }

}
