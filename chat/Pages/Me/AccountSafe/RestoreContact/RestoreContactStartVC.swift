  
  
  
  
  
  
  

import UIKit

class RestoreContactStartVC: BaseViewController {
    
    @IBOutlet var backupBtn: UIButton?
    @IBOutlet var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
      
    func configUI() {
        self.scrollView?.adjustOffset()
        self.backupBtn?.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    @IBAction func onTapConfirm() {
        if let vc = R.loadSB(name: "RestoreContact", iden: "RestoreContactConfirmVC") as? RestoreContactConfirmVC {
            Router.pushViewController(vc: vc)
        }
    }
}
