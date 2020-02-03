  
  
  
  
  
  
  

import Foundation

open class Router:NSObject {
      
    public static var rootWindow: UIWindow?
    
    public static func pushViewController(vc: UIViewController, animate:Bool = true) {
        self.pushViewController(vc: vc, animate: animate, checkSameClass: false)
    }
    
    public static func pushViewController(vc: UIViewController, animate:Bool = true, checkSameClass:Bool = false) {
        var nav: UINavigationController? = nil
        if let rootnav = self.topContianerVC as? UINavigationController {
            nav = rootnav
        }
        else if let rootNav = self.rootVC as? UINavigationController {
              
            nav = rootNav
        }
        
        if checkSameClass == true, let vcArray = nav?.viewControllers.reversed() {
            for viewcontroller in  vcArray {
                if viewcontroller.isMember(of: type(of: vc)) {
                    nav?.popToViewController(viewcontroller, animated: true)
                    return
                }
            }
        }
        
        nav?.pushViewController(vc, animated: animate)
    }
    
    
    
    public static func present(vc: UIViewController, animate: Bool = true) {
        vc.modalPresentationStyle = .overCurrentContext
  
        self.topContianerVC?.present(vc, animated: animate, completion: nil)
    }
    
    public static func dismissVC(animate:Bool = true, completion:(() -> Void)? = nil) {
        dismissVC(animate: animate, completion: completion, toRoot:false)
    }
    
    public static func dismissVC(animate:Bool = true, completion:(() -> Void)? = nil, toRoot: Bool? = false) {
        let topVC = self.topContianerVC
        if let topNav =  topVC as? UINavigationController , topNav.viewControllers.count >= 2 {
            if toRoot == true {
                topNav.popToRootViewController(animated: animate)
            } else {
                topNav.popViewController(animated: animate)
            }
            completion?()
        }
        else {
            if toRoot == true {
                rootVC?.dismiss(animated: animate, completion: completion)
            } else {
                topVC?.dismiss(animated: animate, completion: completion)
            }
        }
    }
    
    public static var currentViewOfVC: UIView? {
        return self.currentVC?.view
    }
    public static var currentVC: UIViewController? {
        return self.topOfStackContainerVC
    }
    
    static public var rootVC: UIViewController? {
        return rootWindow?.rootViewController
    }
    
    private static var topOfStackContainerVC: UIViewController? {
        var topVC = self.topContianerVC
        if let topNav =  topVC as? UINavigationController {
            topVC = topNav.topViewController
        }
        if let tabVC = topVC as? UITabBarController {
            topVC = tabVC.selectedViewController
        }
        return topVC
    }
    
    private static var topContianerVC: UIViewController? {
        var container = self.rootVC
        while container?.presentedViewController != nil {
            container = container?.presentedViewController
        }
        return container
    }
}
