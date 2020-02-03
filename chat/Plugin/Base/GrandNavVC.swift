  
  
  
  
  
  
  

import UIKit

class GrandNavVC: UINavigationController , UIGestureRecognizerDelegate , UINavigationControllerDelegate {
    
    var logined: Bool = false
    var obv: NSObjectProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(obv as Any)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          
        handleLoginLogic()
        configEvent()
        
          
        configNavBar()
        
          
        let image = UIImage(named: "返回1")
        self.navigationBar.backIndicatorImage = image;
        self.navigationBar.backIndicatorTransitionMaskImage = image; 
     
        
        self.view.backgroundColor = UIColor(hexString: Config.Color.app_bg_color)
        Router.rootWindow?.backgroundColor = UIColor(hexString: Config.Color.app_bg_color)

        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes =
                [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .semibold)]
        } else {
              
        };
        
          
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
    
    func handleLoginLogic(shouldDealIpal:Bool? = true) -> Void {
        logined = CPAccountHelper.loginUser() != nil
        if logined == true {
            if shouldDealIpal == true {
                IPALManager.shared.resetForLogin()
            }
            let tab = R.loadSB(name: "Main", iden: "main_tab")
            setViewControllers([tab], animated: true)
        }
        else {
            let login = R.loadSB(name: "Login", iden: "LoginVC")
            setViewControllers([login], animated: true)
        }
    }
    
    func switchLuguage() {
          
        handleLoginLogic(shouldDealIpal: false)
        IPALManager.shared.toast = nil
        
          
        if let baseTabVC = self.topViewController as? GrandTabBarVC {
            baseTabVC.selectedIndex = 2   
        }
          
        let vc = R.loadSB(name: "Setting", iden: "SettingVC")
        Router.pushViewController(vc: vc)
    }
    
    
      
    func getUpgradeInfo() {
        let cul = Bundle.currentLanguage().language ?? "en"
        
        NW.requestUrl(path: APPURL.Config.Info,  para: ["os":"2",
                                                        "version":Device.getAppVersion(),
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
        }
    }
}
