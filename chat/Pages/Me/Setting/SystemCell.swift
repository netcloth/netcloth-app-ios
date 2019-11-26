







import Foundation

var key_Separator = "key_Separator"

class SystemCell: UITableViewCell {
    
    @IBInspectable var showLastSeparator: Bool {
        get {
            if let b = objc_getAssociatedObject(self, &key_Separator) {
                return b as! Bool
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &key_Separator, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if self.showLastSeparator == false {
            return
        }
        let subviews = self.allSubViews
        for item in subviews {

            if  "\(type(of: item))".contains("CellSeparatorView") {
                item.isHidden = false
                item.alpha = 1.0
                
                var frame = item.frame
                frame.origin.x += self.separatorInset.left
                frame.size.width -= self.separatorInset.right
                item.frame  = frame
            }
        }
    }
}

class SysSelecterCell: SystemCell {
    @IBOutlet weak var rightOption: UIView!
}



