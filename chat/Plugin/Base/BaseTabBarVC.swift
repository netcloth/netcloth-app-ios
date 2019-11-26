







import UIKit
import swift_cli

class BaseTabBarVC: UITabBarController {
    
    deinit {
        print("dealloc - " + self.className())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideBlackLine()
        configUI()
        

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { [weak self] in
            self?.configThirdPart()
        }
    }
    
    override func viewWillLayoutSubviews() {
        let ch: CGFloat = 54.0
        self.tabBar.height = ch
        if #available(iOS 11.0, *) {
            self.tabBar.top = self.view.height - ch - self.view.safeAreaInsets.bottom
        } else {

            self.tabBar.top = self.view.height - ch
        }

        for item in (self.tabBar.items ?? []) {
            item.setStyle(textColor: UIColor(hexString: "#BFC2CC"),
                          selectedColor: UIColor(hexString: "#3D7EFF"))
        }
    }
    
    func configUI() {
        self.view.backgroundColor = UIColor(hexString: Config.Color.app_bg_color)
        self.tabBar.setShadow(color: UIColor.lightGray, offset: CGSize(width: 0,height: -5), radius: 5, opacity: 0.1)
    }
    
    func configThirdPart() {
        try? Bugly.start(withAppId: Config.Bugly_APP_ID)
    }
    
}
