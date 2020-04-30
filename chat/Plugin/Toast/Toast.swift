







import UIKit
import swift_cli
import Toast_Swift

extension UIViewController {
    func showLoading() {
        self.view.makeToastActivity(.center)
    }
    
    func dismissLoading() {
        self.view.hideToastActivity()
    }
}

class Toast: NSObject {
    static func show(msg: String, onWindow:Bool = false) {
        show(msg: msg, position: .center, onWindow: onWindow)
    }
    
    static func show(msg:String,
                     position:ToastPosition = ToastPosition.center,
                     onWindow:Bool = false) {
        
        assert(msg != "Warning", "msg must not be")
        (onWindow ? Router.rootWindow : Router.currentViewOfVC)?.makeToast(msg, position:position)
    }
    
}


class Alert: NSObject {
    static func showSimpleAlert(title: String?,
                                msg: String?,
                                cancelAction: (() -> Void)? = nil,
                                okAction: (() -> Void)? = nil,
                                cancelTitle: String? = NSLocalizedString("Cancel", comment: ""),
                                okTitle: String? = NSLocalizedString("OK", comment: "")) {
        
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        if cancelTitle != nil {
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { (action) in
                if let c = cancelAction {
                    c()
                }
            }
            a.addAction(cancel)
        }
        
        if okTitle != nil {
            let ok = UIAlertAction(title: okTitle, style: .default) { (action) in
                if let o = okAction {
                    o()
                }
            }
            a.addAction(ok)
        }
        
        Router.present(vc: a)
    }
}
