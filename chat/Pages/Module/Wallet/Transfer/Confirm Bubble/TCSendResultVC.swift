







import UIKit

class TCSendResultVC: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bubbleView?.confirmObserver.sendResultBack?()
    }
}
