







import UIKit

class ProtocolAlertView: AlertView, NCAlertInterface {
    
    @IBOutlet weak var msgTV: LoginAlertTextView?
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}
