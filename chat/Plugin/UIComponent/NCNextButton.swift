







import UIKit

class NCNextButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setShadow(color: self.backgroundColor ?? UIColor(hexString: Color.shadow_Layer)!,
                       offset: CGSize(width: 0,height: 10),
                       radius: 20,
                       opacity: 0.2)
    }
}
