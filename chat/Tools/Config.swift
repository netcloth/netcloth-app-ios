//
//  Config.swift
//  chat
//
//  Created by Grand on 2019/7/25.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

enum ProductID {
    case NetCloth
    case QDao
    case Undefine
}

class Config: NSObject {
    
    #if DEBUG
    static let Bugly_APP_ID = "a13472f7fe"
    #else
    static let Bugly_APP_ID = "893390c99f"
    #endif
    
    static var curPID: ProductID {
        get {
            if AppBundle.getAppBundleId() == "com.netcloth.chat" {
                return .NetCloth
            }
            return .Undefine
        }
    }
    
    static var UM_AppKey: String {
        get {
            if curPID == .NetCloth {
                return "5e79e750570df36c84000212"
            }
            if curPID == .QDao {
                return "5e79b4980cafb2c74b000c66"
            }
            
            ///undefine
            return "5e7dc67f570df335bc00019c"
        }
    }
    
    static let officialNodeAddress = "nch10jzpt32gwradv9mcnr6fuuj0tnx7rq0psmmtju"
    
    
    static let firstAccountInstall = "caFAI"
    static let Time_Diff = (5 * 60)
    
    class NetOfficial {
        
        static var PrivacyUrl:String {
            get {
                if Bundle.is_zh_Hans() {
                    return  StoreApi + "/NetClothPrivacyPolicy_zh.htm"
                }
                else {
                   return  StoreApi + "/NetClothPrivacyPolicy.htm"
                }
            }
        }
        static var ServiceUrl:String {
            get {
                if Bundle.is_zh_Hans() {
                    return  StoreApi + "/TermsofService_zh.htm"
                }
                else {
                    return  StoreApi + "/TermsofService.htm"
                }
            }
        }
    }
    
    static var Older_Had_Tip: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "Older_T")
        }
        get {
            if let v = UserDefaults.standard.value(forKey: "Older_T") as? Bool {
                return v
            }
            return false
        }
    }
    
    static var In_ACV: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "In_ACV")
        }
        get {
            if let v = UserDefaults.standard.value(forKey: "In_ACV") as? Bool {
                return v
            }
            return true
        }
    }
    
    /// custom debug
    static var isCusDeb: Bool {
        if let obj = UserDefaults.standard.object(forKey: "CusDeb") as? String, obj == "cd" {
            return true
        }
        return false
    }
    
    
    class Group {
        static let Max_Name_Len = 32;
        static let Max_Notice_Len = 200;
        
        /// check name
        static func checkName(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count <= Max_Name_Len else {
                return false
            }
            return true
        }
        /// check notice
        static func checkNotice(_ name1: String?) -> Bool {
            guard let name = name1, name.count <= Max_Notice_Len else {
                return false
            }
            return true
        }
    }
    
    class Account {
        
        static let wallet_exist_tag = "wallet_e_tag"
        
        static let Min_Account_Len = 1;
        static let Min_loginPwd_len = 6;
        
        static let Min_Remark_len = 1;
        static let Min_ExportPwd_len = 8;
        
        static let Last_Login_Name = "Last_Login_Name"
        
        /// check account
        static func checkAccount(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count >= Config.Account.Min_Account_Len else {
                return false
            }
            return true
        }
        
        /// check longin pwd
        static func checkLoginPwd(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count >= Config.Account.Min_loginPwd_len else {
                return false
            }
            return true
        }
        
        /// check longin pwd
        static func checkExportPwd(_ name1: String?) -> Bool {
            guard let name = name1, name.isEmpty == false, name.count >= Config.Account.Min_ExportPwd_len else {
                return false
            }
            return true
        }
        
        ///change remark
        static func checkRemarkInput(remark: String?) -> Bool {
            guard let name = remark, name.isEmpty == false, name.count >= Config.Account.Min_Remark_len else {
                return false
            }
            return true
        }
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
        
        static var muteBlackAble: Bool {
            set {
                UserSettings.setObject(newValue, forKey: "muteBlackAble")
            }
            get {
                if let b = UserSettings.object(forKey: "muteBlackAble") as? Bool {
                    return b
                }
                return true
            }
        }
    }
}

//MARK:- NotificationCenter
enum NoticeNameKey: String {
    
    case loginStateChange
    
    case contactRemarkChange //修改了联系人ramark
    case chatRecordDeletes //清空会话聊天记录
    
    case newFriendsCountChange
    
    case groupNotifyReadStatusChange
    
    /// Unread change
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
