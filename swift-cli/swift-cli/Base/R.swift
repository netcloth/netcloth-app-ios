







import UIKit

open class R: NSObject {
    public static func loadSB(name:String, iden id:String, bundle: Bundle = Bundle.main) -> UIViewController {
        let sb = UIStoryboard(name: name, bundle: bundle)
        return sb.instantiateViewController(withIdentifier: id)
    }
    
    public static func loadNib(name: String, owner: Any? = nil,  in bundle:Bundle? = Bundle.main) -> Any? {
        let nb = bundle?.loadNibNamed(name, owner: owner, options: nil)?.last
        return nb
    }
    
    
    public static func className(of cls: AnyClass) -> String? {
        let t:String = "\(type(of: cls))"
        return t.components(separatedBy: ".").first
    }
}
