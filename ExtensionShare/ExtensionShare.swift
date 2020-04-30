//
//  ExtensionShare.swift
//  chat
//
//  Created by Grand on 2019/11/21.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class ExtensionShare: NSObject {
    static private let chat_group_id = "group.app.chat.netcloth"
    static private let userdefault = UserDefaults(suiteName: chat_group_id)
    
    //MARK:- Public
    static var noDisturb: ExtensionShare {
        get {
            return ExtensionShare(storekey: "notDisturbList")
        }
    }
    
    static var unreadStore: ExtensionShare {
        get {
            return ExtensionShare(storekey: "unreadCount")
        }
    }
    
    //MARK:- helper

    fileprivate var commonKey: String
    init(storekey:String) {
        commonKey = storekey
    }
    
    fileprivate func setObject(_ value: Any?, forKey key: String) {
        ExtensionShare.userdefault?.set(value, forKey: key)
        ExtensionShare.userdefault?.synchronize()
    }
    
    fileprivate func object(forkey: String) -> Any? {
        return ExtensionShare.userdefault?.object(forKey: forkey)
    }
}

//MARK:- 未读消息
extension ExtensionShare {
    func setUnreadCount(_ count: Int) {
        self.setObject(count, forKey: commonKey)
    }
    
    func getUnreadCount() -> Int {
        let r = self.object(forkey: commonKey)
        if let c = r as? Int {
            return c
        }
        return 0
    }
}


//MARK:- 免打扰
extension ExtensionShare {
    
    func addToDisturb(pubkey: String) {
        let store = dealPubkey(pubkey: pubkey)
        var asset_ : Set<String>?
        
        let data = self.object(forkey: commonKey) as? Data
        if let d = data, let asset = try? PropertyListDecoder().decode(Set<String>.self, from: d) {
            asset_ = asset
        } else {
            asset_ = Set<String>()
        }
        asset_?.insert(store)
        
        if let a = asset_ {
            let data = try? PropertyListEncoder().encode(a)
            self.setObject(data, forKey: commonKey)
        }
    }
    
    func removeDisturb(pubkey: String) {
        let store = dealPubkey(pubkey: pubkey)
        var asset_ : Set<String>?
        
        let data = self.object(forkey: commonKey) as? Data
        if let d = data, let asset = try? PropertyListDecoder().decode(Set<String>.self, from: d) {
            asset_ = asset
        } else {
            return
        }
        
        asset_?.remove(store)
        if let a = asset_ {
            let data = try? PropertyListEncoder().encode(a)
            self.setObject(data, forKey: commonKey)
        }
    }
    
    func isInDisturb(pubkey: String) -> Bool {
        let store = dealPubkey(pubkey: pubkey)
        var asset_ : Set<String>?
        
        let data = self.object(forkey: commonKey) as? Data
        if let d = data, let asset = try? PropertyListDecoder().decode(Set<String>.self, from: d) {
            asset_ = asset
        } else {
            return false
        }
        
        if let a = asset_ {
            return a.contains(store)
        }
        return false
    }
    
    func dealPubkey(pubkey: String) -> String {
        if pubkey.count >= 32 {
            return String(pubkey.prefix(18))
        }
        return pubkey
    }
}
