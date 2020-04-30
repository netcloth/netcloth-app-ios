







import UIKit
import WMPageController
import RxSwift
import IQKeyboardManagerSwift

class CreateWalletVC: WMPageController {
    
    deinit {
        print("\(type(of: self))")
        NCUserCenter.shared?.walletManage.value.inCreatingWallet = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = false
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            
        }
        self.configUI()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        NCUserCenter.shared?.walletManage.value.inCreatingWallet = true
    }
    
    func configUI() {
        self.menuView?.layoutMode = .center
        self.menuItemWidth = YYScreenSize().width / 2
        self.menuView?.backgroundColor = UIColor(hexString: Color.gray_f4)
        
        self.titleColorSelected = UIColor(hexString: Color.blue)!
        self.titleColorNormal = UIColor(hexString: Color.gray_62)!
        
        self.reloadData()
    }
    
    
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 2
    }
    
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        if index == 0 {
            let vc = R.loadSB(name: "CreateWallet", iden: "ActivateKeystoreVC")
            return vc
        }
        else {
            let vc = R.loadSB(name: "CreateWallet", iden: "ActivatePrivatekeyVC")
            return vc
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

