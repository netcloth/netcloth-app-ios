







import Foundation
import SDWebImage

extension UIImageView {
    
    
    
    enum UseType {
        case assist
    }
    
    func nc_typeImage(url: String, type: UseType = .assist) {
        nc_imageSet(url: url, placeImage: nil)
    }
    
    func nc_imageSet(url: String,placeImage: UIImage? = nil) {
        let rurl = URL(string: url)
        self.sd_setImage(with: rurl, placeholderImage: placeImage)
    }
    
}
