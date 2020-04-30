







import UIKit
import WMPageController

class TokenTradeStatisticsVC: WMPageController {
    
    var disbag = DisposeBag()
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    










    
    func configUI() {
        
        self.menuView?.layoutMode = .scatter
        self.automaticallyCalculatesItemWidths = true
        
        self.menuView?.backgroundColor = UIColor(hexString: Color.gray_f4)
        
        self.titleColorSelected = UIColor(hexString: Color.blue)!
        self.titleColorNormal = UIColor(hexString: Color.black)!
        self.titleSizeNormal = 16
        self.titleSizeSelected = 18
        
        
        self.titles = [
            "All".localized(),
            "trade_send".localized(),
            "trade_received".localized(),
            "trade_failed".localized(),
        ]
        
        self.reloadData()
    }
    
    func configEvent() {
        
    }
    
    
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 4
    }
    
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        guard let vc = R.loadSB(name: "TokenTradeStatistics", iden: "TokenTradeListVC") as?  TokenTradeListVC else {
            return UIViewController()
        }
        if index == 0 {
            vc.pageTag = .tradeAll
        }
        else if index == 1 {
            vc.pageTag = .tradeOut
        }
        else if index == 2 {
            vc.pageTag = .tradeIn
        }
        else if index == 3 {
            vc.pageTag = .tradeFail
        }
        return vc
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        let top: CGFloat = 0
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: 59)
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {

        let top: CGFloat = 59
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: self.view.height - top)
    }
}
