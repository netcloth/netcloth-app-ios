







import UIKit

class EmojCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func reloadData(data: Any) {
        guard let ts = data as? String else { return }
        self.textLabel.text = ts
    }
}
