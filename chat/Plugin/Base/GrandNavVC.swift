







import UIKit

class GrandNavVC: UINavigationController , UIGestureRecognizerDelegate , UINavigationControllerDelegate {
    
    var logined: Bool = false
    var obv: NSObjectProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(obv as Any)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configNavBar()
        
        
        let image = UIImage(named: "返回1")
        self.navigationBar.backIndicatorImage = image;
        self.navigationBar.backIndicatorTransitionMaskImage = image;
        
        
        self.view.backgroundColor = UIColor(hexString: Color.app_bg_color)
        Router.rootWindow?.backgroundColor = UIColor(hexString: Color.app_bg_color)
        
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes =
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)]
        } else {
            
        };
        
        
        mainAppLogic()
    }
    
    func mainAppLogic() {
        handleLoginLogic()
        configEvent()
        
        
        getUpgradeInfo()
        
        PPNotificationCenter.shared.resetZeroBadge()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configNavBar() -> Void {
        
        self.interactivePopGestureRecognizer?.delegate = self as! UIGestureRecognizerDelegate;
        self.delegate = self
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count <= 1 {
            return false
        }
        return true
    }
    
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.configBackBarItem()
    }
    
    
    func configEvent() {
        obv =
        NotificationCenter.default.addObserver(forName: NoticeNameKey.loginStateChange.noticeName, object: nil, queue: .main) { [weak self] (notification) in
            self?.handleLoginLogic()
        }
    }
    
    
    func handleLoginLogic() -> Void {
        logined = CPAccountHelper.loginUser() != nil
        if logined == true {
            IPALManager.shared.resetForLogin()
            GlobalStatusStore.shared.onLogin()
            NCUserCenter.onLogoin()
            resetMainPage()
        }
        else {
            resetLoginPage()
            RelateColorCache.removeAll()
        }
    }
    
    func resetMainPage() {
        let tab = R.loadSB(name: "Main", iden: "main_tab")
        setViewControllers([tab], animated: true)
    }
    
    func resetLoginPage() {
        let login = R.loadSB(name: "Login", iden: "LoginVC")
        setViewControllers([login], animated: true)
    }
    
    func switchLuguage() {
        
        resetMainPage()
        IPALManager.shared.toast = nil
        
        
        if let baseTabVC = self.topViewController as? GrandTabBarVC {
            baseTabVC.selectedIndex = 3
        }
        
        let vc = R.loadSB(name: "Settings", iden: "SettingVC")
        Router.pushViewController(vc: vc)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
    
    
    
    func getUpgradeInfo() {
        let cul = Bundle.currentLanguage().language ?? "en"
        let localVersion = AppBundle.getAppVersion()
        NW.requestUrl(path: APPURL.Config.Info,  para: ["os":"2",
                                                        "version":localVersion,
                                                        "language": cul
        ]) { (suc, res) in
            guard let data = res , suc else {
                return
            }
            
            let goWeb = { (url:String?) in
                if let address = url {
                    try? UIApplication.shared.openURL(address.asURL())
                }
            }
            let json = JSON(data)
            
            if json["code"].int == 2 {
                Alert.showSimpleAlert(title: nil, msg: json["message"].string,  okAction: {
                    goWeb(json["download"].string)
                    exit(0)
                }, cancelTitle:nil)
            }
            else if json["code"].int == 1  {
                Alert.showSimpleAlert(title: nil, msg: json["message"].string, cancelAction: nil, okAction: {
                    goWeb(json["download"].string)
                })
            }
            
            if json["version"].string?.compare(localVersion, options: [.numeric]) == ComparisonResult.orderedAscending {
                Config.In_ACV = true
            }
            else {
                Config.In_ACV = false
            }
        }
    }
}
