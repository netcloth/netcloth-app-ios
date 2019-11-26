







import UIKit
import WMPageController
import RxSwift

class BackupContainerVC: WMPageController {
    
    @IBOutlet weak var sureBtn: UIButton!
    var disbag = DisposeBag()
    
    deinit {
        print("\(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = false
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {

        }
        self.configUI()
        self.configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(self.sureBtn)
    }
    
    func configUI() {
        self.menuView?.layoutMode = .center
        self.menuItemWidth = YYScreenSize().width / 2
        self.menuView?.backgroundColor = UIColor(hexString: "#F7F8FA")
        
        self.titleColorSelected = UIColor(hexString: "#3D7EFF")!
        self.titleColorNormal = UIColor(hexString: "#909399")!
        
        self.reloadData()
        
        self.sureBtn.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
    }
    
    func configEvent() {
        self.sureBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.showAlert()
        }).disposed(by: disbag)
    }
    
    func showAlert() {
        guard let alert = R.loadNib(name: "ErrorTipsInputAlert") as? ErrorTipsInputAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        alert.titleLabel?.text = "Enter Password".localized()
        alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
        alert.okButton?.setTitle("Confirm".localized(), for: .normal)
        alert.checkTipsLabel?.text = "login_wrong_pwd".localized()
        alert.checkTipsLabel?.isHidden = true
        alert.inputTextField?.isSecureTextEntry = true
        Router.showAlert(view: alert)
        
        alert.checkPreview = { [weak alert, weak self] in
            let pwd = alert?.inputTextField?.text

            if CPAccountHelper.checkLoginUserPwd(pwd) == false {
                alert?.checkTipsLabel?.isHidden = false
                return false
            }

            if pwd?.checkPassthrough().passthrough == false {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15, execute: {
                    self?.toResignPwd(loginPwd: pwd)
                })
                return true
            }

            self?.toNextStep(loginPwd: pwd)
            return true
        }
    }
    
    func toResignPwd(loginPwd: String?) {
        if let vc = R.loadSB(name: "Export", iden: "PwdStrengthVC") as? PwdStrengthVC {
            vc.loginPwd = loginPwd
            vc.index = Int(self.selectIndex)
            
            Router.pushViewController(vc: vc)
        }
    }
    
    
    struct MyError: Error {
        var msg: String
    }

    func toNextStep(loginPwd: String?) {
        if let lpw = loginPwd {
            
            CPAccountHelper.exportKeystoreAndPrivateKey(lpw, exportPassword: lpw) { [weak self] (r, msg, keystore, prikey) in
                if r == false {
                    Toast.show(msg: msg)
                } else {
                    if let vc = R.loadSB(name: "Export", iden: "ExportDetailVC") as? ExportDetailVC {
                        vc.keyStore = keystore
                        vc.privateKey = prikey
                        vc.index = Int(self?.selectIndex ?? 0)
                        Router.pushViewController(vc: vc)
                    }
                }
                
            }
            






































        }
    }
    

    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 2
    }
    
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        if index == 0 {
            return R.loadSB(name: "Export", iden: "KeyStoreDesVC")
        }
        else {
            return R.loadSB(name: "Export", iden: "PrivateKeyDesVC")
        }
    }
    
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        if index == 0 {
            return "Keystore"
        }
        else {
            return "Private Key".localized()
        }
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        let top = self.navigationController?.navigationBar.frame.maxY ?? 0
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: 48)
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = (self.navigationController?.navigationBar.frame.maxY ?? 0 ) + 48
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: YYScreenSize().height - top)
    }
}

class KeyStoreDesVC: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: "#F7F8FA")
    }
}

class PrivateKeyDesVC: KeyStoreDesVC {
    
}
