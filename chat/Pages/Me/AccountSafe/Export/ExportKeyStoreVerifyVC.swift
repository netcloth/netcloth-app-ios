//
//  ExportKeyStoreVerifyVC.swift
//  chat
//
//  Created by Grand on 2019/9/11.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class ExportKeyStoreVerifyVC: BaseViewController {
    
    @IBOutlet weak var keystoreInput: AutoHeightTextView?
    @IBOutlet weak var exportPwdInput: UITextField?
    @IBOutlet weak var verifyBtn: UIButton?
    
    @IBOutlet weak var adjustLabel: UILabel?
    

    var disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: "#F7F8FA")
        self.adjustLabel?.adjustsFontSizeToFitWidth = true
        
        self.verifyBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        self.verifyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let ks = self?.keystoreInput?.text ,
                let epwd = self?.exportPwdInput?.text {
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
    
    func showValidAlert() {
        if let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert {
            alert.titleLabel?.text = "export_verify_valid_title".localized()
            alert.msgLabel?.text = "export_verify_valid_msg".localized()
            alert.okButton?.setTitle("export_verify_valid_btn".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func showInvalidAlert() {
        
        if let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert {
            alert.titleLabel?.text = "export_verify_error_title".localized()
            alert.msgLabel?.text = "export_verify_error_msg".localized()
            alert.okButton?.setTitle("export_verify_error_btn".localized(), for: .normal)
            Router.showAlert(view: alert)
        }
    }
    
}
