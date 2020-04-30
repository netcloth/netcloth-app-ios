







import UIKit

class WaitAlert: AlertView , NCAlertInterface {
    @IBOutlet weak var activity: UIActivityIndicatorView?
    @IBOutlet weak var bottomL: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activity?.startAnimating()
        bottomL?.textColor = UIColor(hexString: Color.black)
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}
