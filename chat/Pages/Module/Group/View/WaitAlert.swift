  
  
  
  
  
  
  

import UIKit

class WaitAlert: AlertView , NCAlertInterface {
    @IBOutlet weak var activity: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activity?.startAnimating()
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}
