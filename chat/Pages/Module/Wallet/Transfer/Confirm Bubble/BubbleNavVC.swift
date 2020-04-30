







import UIKit

class BubbleNavVC: UINavigationController,  UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let image = UIImage(named: "close_gray")
        self.navigationBar.backIndicatorImage = image;
        self.navigationBar.backIndicatorTransitionMaskImage = image;
                
        self.view.backgroundColor = UIColor(hexString: Color.app_bg_color)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count <= 1 {
            return false
        }
        return true
    }
}
