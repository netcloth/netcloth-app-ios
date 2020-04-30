//
//  ActivateVerifyKeystoreVC.swift
//  chat
//
//  Created by Grand on 2020/4/14.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

class ActivateVerifyKeystoreVC: BaseViewController {
    
    @IBOutlet weak var keystoreInput: AutoHeightTextView?
    @IBOutlet weak var exportPwdInput: UITextField?
    @IBOutlet weak var verifyBtn: UIButton?
    
    @IBOutlet weak var eyeBtn: UIButton?
    
    /// pwd
    var isShowPwd = false {
        didSet {
            exportPwdInput?.isSecureTextEntry = !self.isShowPwd
            let img = self.isShowPwd ? UIImage(named: "open_eye") : UIImage(named: "close")
            eyeBtn?.setImage(img, for: .normal)
        }
    }
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    //MARK:- 
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: Color.gray_f7)
        
        self.verifyBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
        self.isShowPwd = false
    }
    
    func configEvent() {
        
        eyeBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.isShowPwd = !(self?.isShowPwd ?? false)
        }).disposed(by: disbag)
        
        self.verifyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let ks = self?.keystoreInput?.text,
                let epwd = self?.exportPwdInput?.text,
                ks.isEmpty == false,
                epwd.isEmpty == false
            {
                CPAccountHelper.verifyKeystore(ks, exportPwd: epwd, callback: { (verify, msg) in
                    if verify == true {
                        self?.showValidAlert()
                    }
                    else {
                        self?.showInvalidAlert()
                    }
                })
            }
            else {
                Toast.show(msg: "WalletManager.Error.invalidData".localized())
            }
        }).disposed(by: disbag)
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
