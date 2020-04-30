







import Foundation

var key_Separator = "key_Separator"
var key_Defaulter = ""

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
            iskey_Defaulter = false
        }
    }
    
    func showLastSeparator(_ isShow: Bool) {
        objc_setAssociatedObject(self, &key_Separator, isShow, .OBJC_ASSOCIATION_ASSIGN)
        iskey_Defaulter = false
        setNeedsLayout()
    }
    
    var iskey_Defaulter: Bool {
        get {
            if let b = objc_getAssociatedObject(self, &key_Defaulter) {
                return b as! Bool
            }
            return true
        }
        set {
            objc_setAssociatedObject(self, &key_Defaulter, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if iskey_Defaulter {
            return
        }
    
        let subviews = self.allSubViews
        for item in subviews {
            
            if  "\(type(of: item))".contains("CellSeparatorView") {
                item.isHidden = false
                item.alpha = self.showLastSeparator ? 1.0 : 0.0
                
                var frame = item.frame
                frame.origin.x += self.separatorInset.left
                frame.size.width -= self.separatorInset.right
                item.frame  = frame
            }
        }
    }
}

class NCConfigCell: SystemCell {
    @IBOutlet weak var rightOption: UIView!
}



