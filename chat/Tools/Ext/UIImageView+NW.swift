







import Foundation

extension UIImageView {
    
    func nw_setImage(urlString: String, placeImg: UIImage? = nil) {
        self.image = placeImg
        NW.getDataUrl(path: urlString, para: nil) { (r, data) in
            if r == true, let d = data as? Data {
                self.image = UIImage(data: d)
            }
        }
    }
    
}
