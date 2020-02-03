  
  
  
  
  
  
  

import UIKit

class ClaimResponseVC: BaseViewController {
    
    var txHash: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Communication Address".localized()
    }
    
    @IBAction func toDetail() {
        
        if let vc = R.loadSB(name: "IPALResult", iden: "IPALHistoryDetailVC") as? IPALHistoryDetailVC {
            vc.queryHistoryTxHash = txHash
            Router.pushViewController(vc: vc)
        }
    }
}
