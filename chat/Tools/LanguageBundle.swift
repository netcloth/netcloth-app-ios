  
  
  
  
  
  
  

import Foundation
var _bundleKey = "_bundle"

class BundleEx: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = objc_getAssociatedObject(self, &_bundleKey) as? Bundle
        if bundle == nil {
            let str = super.localizedString(forKey: key, value: value, table: tableName)
            return str
        } else {
            let str = bundle!.localizedString(forKey: key, value: value, table: tableName)
            return str
        }
    }
}

public enum CustomLanguage: String {
    case zh_Hans = "zh-Hans"
    case en = "en"
}

extension Bundle {
      
    static func swizzleImp() {
        object_setClass(Bundle.main, BundleEx.self)
    }
    
    
      
    static func recoveryToSystem() {
        
        let ud = UserDefaults.standard
          
        ud.removeObject(forKey: "AppleLanguages")
        ud.removeObject(forKey: "NCAL")
        ud.synchronize()
        
          
        let prefers = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String]
        var pL0 = prefers?.first
        if pL0?.contains(CustomLanguage.zh_Hans.rawValue) == true {
            pL0 = CustomLanguage.zh_Hans.rawValue
        }
        let path: String? = Bundle.main.path(forResource: pL0, ofType: "lproj")
        var bundle: Bundle? = nil
        if path != nil {
            bundle = Bundle(path: path!)
        }
        if bundle == nil {
            print("recoveryToSystem error language")
        }
          
        objc_setAssociatedObject(Bundle.main, &_bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
      
    static func setCustomLanguage(_ language: CustomLanguage) {
        
        let path: String? = Bundle.main.path(forResource: language.rawValue, ofType: "lproj")
        var bundle: Bundle? = nil
        if path != nil {
            bundle = Bundle(path: path!)
        }
        if bundle == nil {
            print("setCustomLanguage error language")
        }
        
          
        objc_setAssociatedObject(Bundle.main, &_bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let ud = UserDefaults.standard
          
        ud.set([language.rawValue], forKey: "AppleLanguages")
          
        ud.set(language.rawValue, forKey: "NCAL")
        ud.synchronize()
    }
    
    
      
      
      
    static func currentLanguage() -> (language: String?, isManual: Bool){
        if let cl = UserDefaults.standard.object(forKey: "NCAL") as? String {
            return (cl, true)
        }
        else {
              
            if let al = UserDefaults.standard.object(forKey: "AppleLanguages") as? [Any] {
                return (al.first as? String, false)
            }
            return (nil, false)
        }
    }
}


extension Bundle {
    
    static func is_zh_Hans() -> Bool {
        let (language, isManual)  = Bundle.currentLanguage()
        
        if isManual {
            return language == CustomLanguage.zh_Hans.rawValue
        }
        else {
            return language?.contains(CustomLanguage.zh_Hans.rawValue) == true
        }
    }
}
