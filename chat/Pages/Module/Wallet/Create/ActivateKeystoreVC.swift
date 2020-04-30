//
//  ActivateKeystoreVC.swift
//  chat
//
//  Created by Grand on 2020/4/14.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

class ActivateKeystoreVC: BaseViewController {
    
    @IBOutlet weak var keystoreInput: AutoHeightTextView?
    @IBOutlet weak var passwordInput: UITextField?
    @IBOutlet weak var sureBtn: UIButton?
    @IBOutlet weak var eyeBtn: UIButton?
    @IBOutlet weak var getKeystoreControl: UIControl?
    
    let disbag = DisposeBag()
    
    /// pwd
    var isShowPwd = false {
        didSet {
            passwordInput?.isSecureTextEntry = !self.isShowPwd
            let img = self.isShowPwd ? UIImage(named: "open_eye") : UIImage(named: "close")
            eyeBtn?.setImage(img, for: .normal)
        }
    }
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.isShowPwd = false
        self.view?.backgroundColor = UIColor(hexString: Color.gray_f4)
        self.sureBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        
        eyeBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.isShowPwd = !(self?.isShowPwd ?? false)
        }).disposed(by: disbag)
        
        // import
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            let r = self?.checkInputAvalid()
            if r?.result == false {
                Toast.show(msg: r?.msg ?? "")
            }
            else {
                if let ks = self?.keystoreInput?.text,
                    let epwd = self?.passwordInput?.text {
                    CPAccountHelper.verifyKeystore(ks, exportPwd: epwd, callback: { (verify, msg) in
                        if verify == true {
                            self?.showValidAlert()
                        }
                        else {
                            self?.showInvalidAlert()
                        }
                    })
                }
            }
        }).disposed(by: disbag)
        
        self.getKeystoreControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            
            if let vc = R.loadSB(name: "Export", iden: "BackupContainerVC") as? BackupContainerVC {
                Router.pushViewController(vc: vc)
                vc.selectIndex = 0
            }
        }).disposed(by: disbag)
    }
    
    
    //MARK:- Helper
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard let ks = keystoreInput?.text, ks.count > 0  else {
            return (false,"WalletManager.Error.invalidData".localized());
        }
        guard Config.Account.checkExportPwd(passwordInput?.text) else {
            return (false,"Export_invalid_pwd".localized());
        }
        return (true, "valid data".localized())
    }
    
    /// succ
    func showValidAlert() {
        
        UserSettings.setObject("1", forKey: Config.Account.wallet_exist_tag)
        NCUserCenter.shared?.walletManage.value.inCreatingWallet = false
        Router.dismissVC(animate: false, toRoot: true)
        
        if let rootVC = Router.rootVC as? UINavigationController,
            let baseTabVC = rootVC.topViewController as? GrandTabBarVC,
            let meVc = baseTabVC.selectedViewController as? MeVC
        {
            meVc.toWallet()
        }
        
        if let v = R.loadNib(name: "MayImageAlertView") as? MayImageAlertView {
            v.imageV?.image = UIImage(named: "create_success")
            v.cancelButton?.isHidden = true
            v.msgLabel?.isHidden = true
            v.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            v.titleLabel?.text = "Activate_succ_tip".localized()
            v.okButton?.setTitle("OK_Yeah".localized(), for: .normal)
            Router.showAlert(view: v)
        }
    }
    
    /// fail
    func showInvalidAlert() {
        
        if let v = R.loadNib(name: "MayImageAlertView") as? MayImageAlertView {
            v.imageV?.image = UIImage(named: "create_fail")
            v.cancelButton?.isHidden = true
            v.titleLabel?.text = "Activate_fail_tip".localized()
            v.msgLabel?.text = "Activate_fail_keystore".localized()
            v.okButton?.setTitle("Try Again".localized(), for: .normal)
            Router.showAlert(view: v)
        }
    }
}
