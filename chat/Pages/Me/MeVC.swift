//
//  MeVC.swift
//  chat
//
//  Created by Grand on 2019/7/25.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import FCFileManager
import MessageUI

class MeVC: BaseViewController
    ,MFMailComposeViewControllerDelegate
{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageV: UIImageView!
    
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var copyKeyBtn: UIButton!
    
    @IBOutlet weak var showqrBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var safeControl: UIControl!
    @IBOutlet weak var settingControl: UIControl!
    @IBOutlet weak var aboutControl: UIControl!
    
    @IBOutlet weak var editControl: UIControl?
    
    @IBOutlet weak var hubImage: UIImageView?
    @IBOutlet weak var hubLabel: UILabel?
    
    @IBOutlet weak var walletControl: UIControl?
    @IBOutlet weak var avatarTop: NSLayoutConstraint?
    
    
    let disposeBag = DisposeBag()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
        configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameL.text = (CPAccountHelper.loginUser()?.accountName ?? "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleConnectChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK:- Helper
    func configEvent() {
        
        //edit
        editControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "Rename", iden: "RenameVC")
            Router.pushViewController(vc: vc)
        })
            .disposed(by: disposeBag)
        
        copyKeyBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let pubkey = CPAccountHelper.loginUser()?.publicKey {
                UIPasteboard.general.string = pubkey
                Toast.show(msg: NSLocalizedString("Copy Share", comment: ""))
            }
        })
            .disposed(by: disposeBag)
        
        showqrBtn.rx.tap.subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "QrCode", iden: "QrCodeVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        
        logoutBtn.rx.tap.subscribe(onNext: { [weak self] in
            MeVC.onLogout()
        }).disposed(by: disposeBag)
        
        
        //MARK account safe
        safeControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "AccountSafe", iden: "AccountSafeVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        
        //setting
        settingControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "Settings", iden: "SettingVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        
        //about
        aboutControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "About", iden: "AboutVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        
        /// wallet
        walletControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.toWallet()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: NSNotification.Name.serviceConnectStatusChange, object: nil)
    }
    
    func configUI() -> Void {
        
        self.scrollView.adjustOffset()
        self.logoutBtn.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
        self.tabBarItem.setStyle(imgName: "我的-未选中",
                                 selectedName: "我的-选中",
                                 textColor: UIColor(hexString: Color.gray),
                                 selectedColor: UIColor(hexString: Color.blue))
        
        let pbkey = CPAccountHelper.loginUser()?.publicKey
        self.publicKeyLabel.text = pbkey
        
        //debug
        let tap = UITapGestureRecognizer { [weak self] _ in
            self?.sendDebugDBInfo()
        }
        tap.numberOfTapsRequired = 5
        avatarImageV.isUserInteractionEnabled = true;
        avatarImageV.addGestureRecognizer(tap)
        
        configTop()
        
        /// hide in china
//        if (Config.isCusDeb == false) &&
//            (Bundle.is_zh_Hans() == true) &&
//            Config.In_ACV
//        {
//            let sv =  walletControl?.superview
//            sv?.isHidden = true
//            sv?.clipsToBounds = true
//            sv?.snp.remakeConstraints({ (maker) in
//                maker.height.equalTo(0)
//            })
//        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        } else {
            // Fallback on earlier versions
        }
        configTop()
    }
    
    func configTop() {
        if #available(iOS 11.0, *) {
            avatarTop?.constant = self.view.safeAreaInsets.top + 25
        } else {
            // Fallback on earlier versions
            avatarTop?.constant = 25
        }
    }
    
    //MARK:- Action
    func toWallet() {
        
        if let vc = R.loadSB(name: "WalletIndexVC", iden: "WalletIndexVC") as? WalletIndexVC {
            Router.pushViewController(vc: vc)
        }
//        let isWalletExist = UserSettings.object(forKey: Config.Account.wallet_exist_tag)
//
//        if let tag = isWalletExist as? String, tag == "1" {
//            if let vc = R.loadSB(name: "WalletIndexVC", iden: "WalletIndexVC") as? WalletIndexVC {
//                Router.pushViewController(vc: vc)
//            }
//        }
//        else {
//
//            _ = showWalletCreateAlert().subscribe(onNext: { () in
//                if let vc = R.loadSB(name: "CreateWallet", iden: "CreateWalletVC") as? CreateWalletVC {
//                    Router.pushViewController(vc: vc)
//                }
//            })
//        }
        
    }
    
    func showWalletCreateAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                //config
                alert.titleLabel?.text = "Wellet_First_Tip".localized()
                alert.msgLabel?.isHidden = true
                
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Confirm".localized(), for: .normal)
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onNext(())
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }
    
    //MARK:-
    
    static func onLogout() {
        Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Log Out", comment: ""), cancelAction: nil, okAction: {
            MeVC._logout()
        })
    }
    
    static func _logout(_ post:Bool = true) {
        
        let block = {
            CPAccountHelper.logout { (r, msg) in
                Router.rootWindow?.hideToastActivity()
                NCUserCenter.onLogout()
                if post {
                    _postNotify()
                }
            }
        }
        
        Router.rootWindow?.makeToastActivity(.center)
        if let v =  UserSettings.object(forKey: KClearWhenLogout) as? String, v == "1" {
           //delete all chats
            CPSessionHelper.deleteAllSessionComplete { (r, msg) in
                block()
            }
        }
        else {
            block()
        }
    }
    
    
    /// 通知切换到 登陆场景
    static func _postNotify() {
        NotificationCenter.post(name: .loginStateChange)
    }
    
    @objc func handleConnectChange() {
        let isClaimOk = IPALManager.shared.store.currentCIpal?.isClaimOk == 1
        let isClaimFail = IPALManager.shared.store.currentCIpal?.isClaimOk == 2
        
        if CPAccountHelper.isConnected() && isClaimOk {
            hubImage?.image = UIImage(named: "connect_ok")
            hubLabel?.text = "connect_ok".localized()
        } else {
            if CPAccountHelper.isNetworkOk() && !isClaimFail {
                hubImage?.image = UIImage(named: "connect_ing")
                hubLabel?.text = "connect_ing".localized()
            } else {
                hubImage?.image = UIImage(named: "connect_fail")
                hubLabel?.text = "connect_fail".localized()
            }
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Debug
    func sendDebugDBInfo() {
        guard MFMailComposeViewController.canSendMail() else {
            Toast.show(msg: "please check your email")
            return
        }
        self.showLoading()
        DispatchQueue.global().async {
            
            let logsData = CPChatLog.zipLogs()
            guard let logd = logsData else {
                DispatchQueue.main.async {
                    self.dismissLoading()
                }
                return;
            }
            
            DispatchQueue.main.async {
                self.dismissLoading()
                let mf = MFMailComposeViewController()
                mf.setToRecipients(["log@netcloth.org"])
                
                //file log
                let name = String(CPAccountHelper.loginUser()?.publicKey.prefix(16) ?? "logs")
                mf.addAttachmentData(logd as Data, mimeType: "zip", fileName: "\(name).zip")
                
                mf.mailComposeDelegate = self
                Router.present(vc: mf, animate: true)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        if result == .sent {
            Toast.show(msg: "send")
        }
    }
}
