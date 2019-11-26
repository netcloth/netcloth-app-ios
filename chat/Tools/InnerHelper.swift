







import UIKit

class InnerHelper: NSObject {
    
    static func toString(contact: CPContact) -> String? {
        return toContactString(pubkey: contact.publicKey, alias: contact.remark)
    }
    
    static func toContactString(pubkey: String, alias: String) -> String? {
        var dic:NSMutableDictionary = NSMutableDictionary()
        dic["netcloth"] = "contact"
        dic["version"] = 1
        dic["alias"] = alias
        dic["address"] = pubkey
        return dic.modelToJSONString()
    }
    
    static func decodeJson(str: Any, wantType: String) -> (valid: Bool, data: Any?, minorData: Any?) {
        
        guard let _str = str as? String else {
            return (false, nil, nil)
        }
        
        if let dic =  _str.jsonValueDecoded() as? NSDictionary {
            if let _want = dic.object(forKey: "netcloth") as? String, _want == wantType {

                if wantType == "contact" {
                    let _d = dic["address"]
                    let _m = dic["alias"]
                    return (true, _d, _m)
                } else {

                    return (false, nil, nil)
                }
                
            } else {

                return (false, nil, nil)
            }
        } else {

            return (true, _str, nil)
        }
    }
}
