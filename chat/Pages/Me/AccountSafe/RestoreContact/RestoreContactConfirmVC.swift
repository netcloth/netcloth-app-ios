//
//  ContactBackupConfirmVC.swift
//  chat
//
//  Created by Grand on 2019/10/29.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import PromiseKit

class RestoreContactConfirmVC: BaseViewController {
    
    @IBOutlet var scrollView: UIScrollView?
    @IBOutlet var timeL: UILabel?
    @IBOutlet var listL: UILabel?
    @IBOutlet var confirmBtn: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        requestSummary()
    }
    
    //MARK:- Config
    func configUI() {
        self.scrollView?.adjustOffset()
        self.confirmBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
    }
    
    func requestSummary() {
        if let pbkey = CPAccountHelper.loginUser()?.publicKey {
            self.showLoading()
            let url = APPURL.Config.ContactsSummary.replacingOccurrences(of: "{pubkey}", with: pbkey)
            NW.getDataUrl(path: url, method: .get, para: nil) { [weak self] (success, res) in
                if success == false {
                    self?.dismissLoading()
                } else if let d = res as? Data {
                    CPContactHelper.decodeContactSummary(d) { (r, msg, dic) in
                        if r == true , let result = dic as? NSDictionary {
                            let json = JSON(result)
                            let backupTime = (json["data"]["backupTime"].int64 ?? 0) / 1000
                            let date = NSDate(timeIntervalSince1970: TimeInterval(backupTime))
                            let str_d = date.string(withFormat: "yyyy-MM-dd HH:mm")
                            
                            let whiteN = json["data"]["count"]["contact"].int ?? 0
                            let blackN = json["data"]["count"]["blacklist"].int ?? 0
                            let groupN = json["data"]["count"]["group"].int ?? 0
                            
                            self?.fillUI(time: str_d ?? "", whiteN: whiteN, blackN: blackN, groupN: groupN)
                        }
                        self?.dismissLoading()
                    }
                } else {
                    self?.dismissLoading()
                }
            }
        } else {
            Toast.show(msg: "System error".localized())
        }
    }
    
    func fillUI(time: String, whiteN: Int, blackN: Int, groupN: Int) {
        //current
        self.timeL?.text = time
        var tip = "Contact_info".localized()
        var atttip = NSMutableAttributedString(string: tip)
        
        let range1 = (atttip.string as? NSString)?.range(of: "#white#")
        if let r1 = range1, r1.location != NSNotFound {
            let a1 = NSMutableAttributedString(string: "\(whiteN)")
            a1.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
            NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: a1.rangeOfAll())
            atttip.replaceCharacters(in: r1, with: a1)
        }
        
        let range2 = (atttip.string as? NSString)?.range(of: "#black#")
        if let r1 = range2 {
            let a1 = NSMutableAttributedString(string: "\(blackN)")
            a1.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
            NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: a1.rangeOfAll())
            atttip.replaceCharacters(in: r1, with: a1)
        }
        let range3 = (atttip.string as? NSString)?.range(of: "#group#")
        if let r1 = range3 {
            let a1 = NSMutableAttributedString(string: "\(groupN)")
            a1.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold),
            NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: a1.rangeOfAll())
            atttip.replaceCharacters(in: r1, with: a1)
        }
        
        self.listL?.attributedText = atttip
    }
    
    //MARK:- Action

    
    @IBAction func onTapConfirm() {
        
        self.popAlert()?
            .then { (res) -> Promise<Data>  in
                self.showProgress()
                return self.downloadContact()
        }
        .then{ (data) -> Promise<String> in
            return self.decodeDatabase(data)
        }
        .done { (result) in
            
            //update do not disturb
            CPContactHelper.getAllContacts { (result) in
                for contact in result {
                    if (contact.isDoNotDisturb) {
                        ExtensionShare.noDisturb.addToDisturb(pubkey: contact.publicKey)
                    }
                }
            }
            
            
            self.hideProgress { [weak self] in
                if result == "success" {
                    self?.showSuccessUploadAlert()
                }
            }
            
        }
        .catch { error in
            print(error)
            self.hideProgress { [weak self] in
                if let e = error as? NSError, e.code != 0 {
                    Toast.show(msg: "System error".localized())
                    if CPAccountHelper.isNetworkOk() == false {
                        self?.showFailUploadAlert()
                    }
                }
            }
        }
    }
    
    func showSuccessUploadAlert() {
        guard let successV = R.loadNib(name: "UploadResultAlert") as? UploadResultAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        successV.imageView?.image = UIImage(named: "backup_result_success")
        successV.msgLabel?.text = "Contact_restore_result_success".localized()
        successV.okButton?.setTitle("OK".localized(), for: .normal)
        Router.showAlert(view: successV)
        successV.okBlock = { [weak self] in
            //to safe page
            if let vcs = self?.navigationController?.viewControllers {
                for v in vcs {
                    if v is AccountSafeVC {
                        self?.navigationController?.popToViewController(v, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    func showFailUploadAlert() {
        guard let failV = R.loadNib(name: "UploadResultAlert") as? UploadResultAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        failV.imageView?.image = UIImage(named: "backup_result_fail")
        failV.msgLabel?.text = "Contact_restore_result_fail".localized()
        failV.okButton?.setTitle("OK".localized(), for: .normal)
        Router.showAlert(view: failV)
        failV.okBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- Progress
    
    weak var progressView: UploadProgressView?
    
    func showProgress() {
        guard let progressV = R.loadNib(name: "UploadProgressView") as? UploadProgressView  else {
            Toast.show(msg: "System error".localized())
            return
        }
        progressV.msgLabel?.text = "Contact_restore_tip".localized()
        Router.showAlert(view: progressV)
        progressView = progressV
    }
    func hideProgress(_ completion:(() -> Void)? = nil) {
        if let p = progressView {
            Router.dismissVC(animate: true, completion: completion)
        } else {
            completion?()
        }
    }
    
    func updateProgress(_ progress: Double) {
        if let p = progressView {
            p.progress = progress
        }
    }
    
    
    func popAlert() -> Promise<String>?  {
        guard let alert = R.loadNib(name: "ErrorTipsInputAlert") as? ErrorTipsInputAlert  else {
            Toast.show(msg: "System error".localized())
            return nil
        }
        
        let alert_promise = Promise<String> { [weak self] (resolver) in
            
            alert.titleLabel?.text = "Enter Password".localized()
            alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            alert.checkTipsLabel?.text = "login_wrong_pwd".localized()
            alert.checkTipsLabel?.isHidden = true
            alert.inputTextField?.isSecureTextEntry = true
            Router.showAlert(view: alert)
            
            alert.checkPreview = { [weak alert] in
                let pwd = alert?.inputTextField?.text
                //check if error
                if CPAccountHelper.checkLoginUserPwd(pwd) == false {
                    alert?.checkTipsLabel?.isHidden = false
                    return false
                }
                return true
            }
            
            alert.cancelBlock = {
                let error = NSError(domain: "restore", code: 0, userInfo: nil)
                resolver.reject(error)
            }
            
            alert.okBlock = {
                resolver.fulfill("ok")
            }
        }
        return alert_promise
    }
    
    func decodeDatabase(_ data:Data) -> Promise<String> {
        let data_promise = Promise<String> { [weak self] (resolver) in
            CPContactHelper.restoreContactContent(data) { (r, msg) in
                if r == false {
                    let error = NSError(domain: "restore", code: 1, userInfo: nil)
                    resolver.reject(error)
                } else {
                    resolver.fulfill("success")
                }
            }
        }
        return data_promise
    }
    
    //MARK:- download
    func downloadContact() -> Promise<Data> {
        
        let _promise = Promise<Data> { [weak self] (resolver) in
            if let pbkey = CPAccountHelper.loginUser()?.publicKey {
                let url = APPURL.Config.ContactsContent.replacingOccurrences(of: "{pubkey}", with: pbkey)
                NW.getDataUrl(path: url, method: .get, para: nil) { [weak self] (success, res) in
                    if success , let d = res as? Data {
                        self?.updateProgress(0.3)
                        resolver.fulfill(d)
                    } else {
                        let error = NSError(domain: "restore", code: 2, userInfo: nil)
                        resolver.reject(error)
                    }
                }
            } else {
                let error = NSError(domain: "restore", code: 2, userInfo: nil)
                resolver.reject(error)
            }
        }
        return _promise
    }
}
