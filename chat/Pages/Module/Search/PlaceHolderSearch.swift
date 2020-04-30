







import Foundation

class PlaceHolderSearch: UIView {
    @IBOutlet weak var tipL: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tipL?.text = "Search".localized()
    }
    
}
