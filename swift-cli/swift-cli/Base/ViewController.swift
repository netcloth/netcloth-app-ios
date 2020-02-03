  
  
  
  
  
  
  

import Foundation
import ObjectiveC

var key_hidebar = "key_hidebar"
var key_initData = "key_initData"
var key_large = "key_large"

@objc public protocol  BarControl  {
    var isHideNavBar: Bool {get set}
    
       
    @available(iOS 11.0, *)
    var isShowLargeTitleMode: Bool {get set}
    
    func configBackBarItem()
    func configLeftBarItem()
    
    func whiteStyle()
    func clearStyle()
}

@objc public protocol VCInitData {
    var vcInitData:AnyObject? {get set}
}



extension UIViewController : BarControl, VCInitData {
    
    @available(iOS 11.0, *)
    public var isShowLargeTitleMode: Bool {
        get {
            if let b = objc_getAssociatedObject(self, &key_large) {
                return b as! Bool
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &key_large, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    public func whiteStyle() {
        self.navigationController?.whiteStyle()
    }
    
    public func clearStyle() {
        self.navigationController?.clearStyle()
    }
    
    public var isHideNavBar: Bool {
        get {
            if let b = objc_getAssociatedObject(self, &key_hidebar) {
                return b as! Bool
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &key_hidebar, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public var vcInitData: AnyObject? {
        get {
            return objc_getAssociatedObject(self, &key_initData) as AnyObject?
        }
        set {
            objc_setAssociatedObject(self, &key_initData, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func configBackBarItem() {
        let item = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = item
    }
    
    public func configLeftBarItem() {
        let btn = ExpandBtn(type: .custom)
        btn.setImage(UIImage(named: "返回1")?.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 13, bottom: 1, right: 1), resizingMode: .stretch), for: .normal)
        btn.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.contentHorizontalAlignment = .left
          
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -7, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: btn)
        self.navigationItem.leftBarButtonItem = item
          
          
          
          
    }
    
    @objc public func backAction() {
        Router.dismissVC()
    }
}

  
open class BaseViewController: UIViewController {
    
    deinit {
        print("dealloc - \(type(of: self))")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = self.isShowLargeTitleMode ? .always : .never
        } else {
              
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(self.isHideNavBar, animated: animated)
        self.navigationController?.hideBlackLine()
        whiteStyle()
    }
    
   
}

open class BaseTableViewController : UITableViewController {
    deinit {
        print("dealloc - \(type(of: self))")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = self.isShowLargeTitleMode ? .automatic : .never
        } else {
              
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(self.isHideNavBar, animated: animated)
        self.navigationController?.hideBlackLine()
        whiteStyle()
    }
}



  
extension  UINavigationController {
    
    public func hideBlackLine() {
  
        self.navigationBar.shadowImage = UIImage()
    }
    public func showBlackLine () {
  
        self.navigationBar.shadowImage = nil
    }
    
    public override func whiteStyle() {
        
        var navbg = self.navigationBar.backgroundImage(for: .default)
        if navbg?.size.height == 0
            || navbg == nil {
            navbg = UIImage.imageWithColor(color: UIColor.white)?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.1, left: 0.1, bottom: 0.1, right: 0.1), resizingMode: UIImage.ResizingMode.stretch)
            
            self.navigationBar.setBackgroundImage(navbg, for: .default)
        }
        
        if #available(iOS 11.0, *) {
            for view in self.navigationBar.subviews {
                view.alpha = 1
            }
        } else {
            if let sv = self.navigationBar.subviews.first {
                sv.alpha = 1
            }
        }
        
        navigationBar.isTranslucent = true
  
        self.navigationBar.tintColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
    }
    
    public override func clearStyle() {
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        if #available(iOS 11.0, *) {
            for view in self.navigationBar.subviews {
                view.alpha = 0
            }
        } else {
            if let sv = self.navigationBar.subviews.first {
                sv.alpha = 0
            }
        }
        
        navigationBar.isTranslucent = true
        self.navigationBar.tintColor = UIColor.white
    }
}



extension  UITabBarController {
    public func hideBlackLine() {
        let tabbar = UITabBar.appearance()
        tabbar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
    }
}

extension UIImage {
    static func imageWithColor(color: UIColor) -> UIImage? {
        return self.imageWithColor(color: color, size: CGSize(width: 1, height: 1))
    }

    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        if  size.width <= 0 || size.height <= 0 {
            return nil
        }
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil}
        context.setFillColor(color.cgColor);
        context.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}


extension UITabBarItem {
    
    public func setStyle(imgName:String? = nil,
                         selectedName: String? = nil,
                         textColor:UIColor? = nil,
                         selectedColor:UIColor? = nil,
                         isOrigin:Bool = true
        ) {
        
        var img: UIImage?, sImg :UIImage?, tc: UIColor?, stc: UIColor?
        if let iname = imgName {
            img = UIImage(named: iname)
            if isOrigin {
                img = img?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        if let iname = selectedName {
            sImg = UIImage(named: iname)
            if isOrigin {
                sImg = sImg?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        if let tct = textColor {
            tc = tct
        }
        
        if let tct = selectedColor {
            stc = tct
        }
        
          
        if img != nil {
            self.image = img
        }
        if sImg != nil {
            self.selectedImage = sImg
        }
        
        if let t = tc {
            let attr = [NSAttributedString.Key.foregroundColor: t]
            self.setTitleTextAttributes(attr, for: .normal)
        }
        
        if let t = stc {
            let attr = [NSAttributedString.Key.foregroundColor: t]
            self.setTitleTextAttributes(attr, for: .selected)
        }
    }
    
}



extension UIViewController {
    
      
    open func setCustomTitle(_ title: String,
                             color: UIColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1),
                             font: UIFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)) -> UILabel
    {
        let label = UILabel()
        label.text = title
        label.font = font
        label.textColor = color
        label.textAlignment = .center
        
        self.navigationItem.titleView = label
        return label
    }
}
