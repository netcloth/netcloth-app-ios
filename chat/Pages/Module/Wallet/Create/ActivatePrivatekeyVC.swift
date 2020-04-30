//
//  ActivatePrivatekeyVC.swift
//  chat
//
//  Created by Grand on 2020/4/14.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

class ActivatePrivatekeyVC: BaseViewController {
    
    @IBOutlet weak var getPrivatekeyControl: UIControl?
    @IBOutlet weak var privateKeyInput: AutoHeightTextView?
    @IBOutlet weak var sureBtn: UIButton?
    
    let disbag = DisposeBag()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: Color.gray_f4)
        self.sureBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        
        self.getPrivatekeyControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            
            if let vc = R.loadSB(name: "Export", iden: "BackupContainerVC") as? BackupContainerVC {
                Router.pushViewController(vc: vc)
                vc.selectIndex = 1
            }
        }).disposed(by: disbag)
        
        // 验证私钥
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            
            if let pk = self?.privateKeyInput?.text,
                pk.isEmpty == false {
                CPAccountHelper.verifyPrivateKey(pk) { (r, msg) in
                    if r == true {
                        self?.showValidAlert()
                    }
                    else {
                        self?.showInvalidAlert()
                    }
                }
            }
            else {
                Toast.show(msg: "WalletManager.Error.invalidData".localized())
            }
            
        }).disposed(by: disbag)
    }
    
    //MARK:- Helper
    func checkInputAvalid() -> (result:Bool,msg:String) {
        
        guard let priK = privateKeyInput?.text, priK.count > 0  else {
            return (false,"WalletManager.Error.invalidData".localized());
        }
        return (true, "valid data".localized())
    }
    
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
    
    func showInvalidAlert() {
        
        if let v = R.loadNib(name: "MayImageAlertView") as? MayImageAlertView {
            v.imageV?.image = UIImage(named: "create_fail")
            v.cancelButton?.isHidden = true
            v.titleLabel?.text = "Activate_fail_tip".localized()
            v.msgLabel?.text = "Activate_fail_prikey".localized()
            v.okButton?.setTitle("Try Again".localized(), for: .normal)
            Router.showAlert(view: v)
        }
    }
}
