







import Foundation

public protocol Cell {
    func reloadData(data: Any) -> Void;
    func adjustOffset();
}

extension UITableViewCell: Cell  {
    @objc open func reloadData(data: Any) {
        
    }
    
    @objc open func adjustOffset() {
        if self.responds(to: #selector(getter:separatorInset)) {
            self.separatorInset = .zero
        }
        if self.responds(to: #selector(getter: layoutMargins)) {
            self.layoutMargins = .zero
        }
    }
}

extension UICollectionViewCell: Cell {
    @objc open func reloadData(data: Any) {
    }
    
    @objc open func adjustOffset() {
    }
}


extension UIScrollView: Cell {
    
    @objc open func reloadData(data: Any) {
    }
    
    @objc open func adjustOffset() {
        if let r = self.viewController?.responds(to: #selector(getter: UIViewController.automaticallyAdjustsScrollViewInsets)) ,
            r == true {
            self.viewController?.automaticallyAdjustsScrollViewInsets = false
        }
        
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        } else {

        }
    }
}


extension UITableView: Cell {
    @objc open override func reloadData(data: Any) {
        super.reloadData(data: data)
    }
    
    @objc open override func adjustOffset() {
        
        super.adjustOffset()
        
        if self.responds(to: #selector(getter:UITableView.separatorInset)) {
            self.separatorInset = .zero
        }
        
        if self.responds(to: #selector(getter: layoutMargins)) {
            self.layoutMargins = .zero
        }
    }
    
    open func onlyAdjustTopOffset() {
        super.adjustOffset()
    }
    
    open func adjustFooter() {
        let footer = UIView()
        var rect = footer.frame
        rect.size.height = CGFloat.leastNormalMagnitude
        footer.frame = rect
        self.tableFooterView = footer
    }
    
    open func adjustHeader() {
        let footer = UIView()
        var rect = footer.frame
        rect.size.height = CGFloat.leastNormalMagnitude
        footer.frame = rect
        self.tableHeaderView = footer
    }
    
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    






    open func setShadow(color: UIColor,
                        offset: CGSize = CGSize(width: 0,height: -3),
                        radius:CGFloat = 3.0,
                        opacity: CGFloat = 1.0) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Float(opacity)
    }
    
    
    open func fakesetLayerCornerRadiusAndShadow(_ cornerRadius: CGFloat,
    color: UIColor,
    offset: CGSize = CGSize(width: 0,height: -3),
    radius:CGFloat = 3.0,
    opacity: CGFloat = 1.0) {
        
        let sublayer =  self.layer
        
        sublayer.cornerRadius = cornerRadius
        sublayer.masksToBounds = false
        sublayer.backgroundColor = UIColor.white.cgColor
        
        sublayer.shadowColor = color.cgColor
        sublayer.shadowOffset = offset
        sublayer.shadowRadius = radius
        sublayer.shadowOpacity = Float(opacity)
    }
    
    
    open func setLayerCornerRadiusAndShadow(_ cornerRadius: CGFloat,
                                            color: UIColor,
                                            offset: CGSize = CGSize(width: 0,height: -3),
                                            radius:CGFloat = 3.0,
                                            opacity: CGFloat = 1.0) {
        
        
        let sublayer = CALayer()
        sublayer.frame = self.frame
        sublayer.cornerRadius = cornerRadius
        sublayer.masksToBounds = false
        sublayer.backgroundColor = UIColor.white.cgColor
        
        sublayer.shadowColor = color.cgColor
        sublayer.shadowOffset = offset
        sublayer.shadowRadius = radius
        sublayer.shadowOpacity = Float(opacity)
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        let key = String(format: "%pmu", self)
        if let sv = self.superview {
            if let old = objc_getAssociatedObject(self,key) as? CALayer {
                old.removeFromSuperlayer()
            }
            sv.layer.insertSublayer(sublayer, below: self.layer)
            objc_setAssociatedObject(self, key, sublayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open var viewController: UIViewController? {
        var rsp = self.next
        while rsp != nil {
            if let r = rsp as? UIViewController {
                return r
            }
            rsp = rsp?.next
        }
        return nil
    }
    
    
    open var allAncestorsViews: [UIView] {
        var result: [UIView] = []
        self.recursionFind(upper: true, outResult: &result)
        return result
    }
    
    open var allSubViews: [UIView] {
        var result: [UIView] = []
        self.recursionFind(upper: false, outResult: &result)
        return result
    }
    
    
    private func recursionFind(upper:Bool, outResult: inout [UIView]) {
        
        if upper {
            if self.superview != nil {
                outResult.append(self.superview!)
                self.superview?.recursionFind(upper: upper, outResult: &outResult)
            }
        }
        else {
            if self.subviews.isEmpty == false {
                outResult.append(contentsOf: self.subviews)
                for sv in self.subviews {
                    sv.recursionFind(upper: upper, outResult: &outResult)
                }
            }
        }
    }
}

public protocol ExpandHotZone {
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool
}

extension ExpandHotZone where Self: UIView {
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds.inset(by: UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        return rect.contains(point)
    }
}


open class ExpandBtn: UIButton, ExpandHotZone {
    
}
