  
  
  
  
  
  
  

import UIKit

enum NoticeNameKey: String {
    
    case loginStateChange
    
    case contactRemarkChange   
    case chatRecordDeletes   
    
    case newFriendsCountChange
    
    case groupNotifyReadStatusChange
    
      
    case chatRoomUnreadStatusChange
    
    
    
      
    var stringValue: String {
        return "kN" + rawValue
    }
    var noticeName: NSNotification.Name {
        return NSNotification.Name(stringValue)
    }
}

extension NotificationCenter {
    static func post(name: NoticeNameKey, object: Any? = nil){
        NotificationCenter.default.post(name: name.noticeName, object: object)
    }
}


class Config: NSObject {
    
    #if DEBUG
    static let Bugly_APP_ID = "a13472f7fe"
    #else
    static let Bugly_APP_ID = "893390c99f"
    #endif
    
    
    static let Time_Diff = (5 * 60)
    
    class Group {
        static let Max_Name_Len = 32;
        static let Max_Notice_Len = 200;
        
          
        static func checkName(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count <= Max_Name_Len else {
                return false
            }
            return true
        }
          
        static func checkNotice(_ name1: String?) -> Bool {
            guard let name = name1, name.count <= Max_Notice_Len else {
                return false
            }
            return true
        }
    }
    
    class Account {
        
        static let Min_Account_Len = 1;
        static let Min_loginPwd_len = 6;
        
        static let Min_Remark_len = 1;
        static let Min_ExportPwd_len = 8;
        
        static let Last_Login_Name = "Last_Login_Name"
        
          
        static func checkAccount(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count >= Config.Account.Min_Account_Len else {
                return false
            }
            return true
        }
        
          
        static func checkLoginPwd(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count >= Config.Account.Min_loginPwd_len else {
                return false
            }
            return true
        }
        
          
        static func checkExportPwd(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count >= Config.Account.Min_ExportPwd_len else {
                return false
            }
            return true
        }
        
          
        static func checkRemarkInput(remark: String?) -> Bool {
            guard let name = remark, name.isEmpty == false, name.count >= Config.Account.Min_Remark_len else {
                return false
            }
            return true
        }
    }
    
    
    class Color {
        static let app_bg_color = "#FFFFFF"
        static let shadow_Layer = "#3D7EFF"
        static let mask_bottom_empty = "#EDEFF2"
        static let mask_bottom_fill = "#303133"
    }
    
    class Settings {
        
        static var shakeble:Bool {
            set {
                UserDefaults.standard.set(newValue, forKey: "set_shake")
            }
            get {
                if let ss  = UserDefaults.standard.object(forKey: "set_shake") {
                    return ss as! Bool
                }
                return true
            }
        }
        
        static var bellable:Bool {
            set {
                UserDefaults.standard.set(newValue, forKey: "set_bell")
            }
            get {
                if let ss  = UserDefaults.standard.object(forKey: "set_bell") {
                    return ss as! Bool
                }
                return true
            }
        }
    }
}
