  
  
  
  
  
  
  

import Foundation

extension UIViewController {
    func checkCanReload() -> Bool {
        var topVC = self.navigationController as? UIViewController
        if let topNav =  topVC as? UINavigationController {
            topVC = topNav.topViewController
        }
        if let tabVC = topVC as? UITabBarController {
            topVC = tabVC.selectedViewController
        }
        if topVC == self {
            return true
        }
        return false
    }
}
