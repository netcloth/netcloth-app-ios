//
//  R.swift
//  swift-cli
//
//  Created by Grand on 2019/7/25.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

open class R: NSObject {
    public static func loadSB(name:String, iden id:String, bundle: Bundle = Bundle.main) -> UIViewController {
        let sb = UIStoryboard(name: name, bundle: bundle)
        return sb.instantiateViewController(withIdentifier: id)
    }
    
    public static func loadNib(name: String, owner: Any? = nil,  in bundle:Bundle? = Bundle.main) -> UIView? {
        let nb = bundle?.loadNibNamed(name, owner: owner, options: nil)?.last as? UIView
        return nb
    }
    
    public static func className(of cls: AnyClass) -> String? {
        let t:String = "\(type(of: cls))"
        return t.components(separatedBy: ".").first
    }
}

extension UIViewController {
    public static func loadNib(name nibName: String? = nil ,  in bundle:Bundle? = Bundle.main) -> UIViewController {
        let nib =  nibName ?? self.debugClassName()
        let nb = self.init(nibName: nib, bundle: bundle)
        return nb
    }
    
    public static func debugClassName() -> String {
        let t:String = self.description()
        return t.components(separatedBy: ".").last ?? ""
    }
    
}
