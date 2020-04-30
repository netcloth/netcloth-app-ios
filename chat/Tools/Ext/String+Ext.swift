//
//  StringExt.swift
//  chat
//
//  Created by Grand on 2019/8/2.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

extension String {
    
    func isOnlyEn() -> Bool {
       let range =  self.range(of: "^[A-Za-z ]+$", options: String.CompareOptions.regularExpression)
        if range != nil {
            return true
        }
        return false
    }
    
    func isEnglish() -> Bool {
       let range =  self.range(of: "^[A-Za-z]+$", options: String.CompareOptions.regularExpression)
        if range != nil {
            return true
        }
        return false
    }
    
    //MARK:- remark
    func getSmallRemark() -> String {
        if self.isOnlyEn() == false {
            return String(self.suffix(2))
        }
        else {
            let arr = self.components(separatedBy: " ")
            if arr.count >= 2 {
                let f1 = String(arr[0].prefix(1))
                let f2 = String(arr[1].prefix(1))
                
                return f1 + f2
            }
        }
        return String(self.prefix(2))
    }
    
    func getAvatarOneWord() -> String {
        if self.isOnlyEn() == false {
            return String(self.suffix(1))
        }
        return String(self.prefix(1))
    }
    
    func getPubkeyAbbreviate() -> String {
        return "\(self.prefix(10))……\(self.suffix(10))"
    }
    
    
    
    func getNoWhiteEnterString() -> String? {
        return (self as NSString).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    //MARK:- strong of wallet pwd
    //0. 8 - 16
    //1. A =  1 << 1
    //2. a =  1 << 2
    //3. 3 =  1 << 3
    //4. & =  1 << 4
    
    func checkPassthrough() -> (passthrough: Bool ,strength: Int, ruleCount: Int) {
        if !(self.count >= Config.Account.Min_ExportPwd_len) {
            return (false, 0, 0)
        }
        return self.checkWalletPwdStrength()
    }
    
    func checkWalletPwdStrength() -> (passthrough: Bool ,strength: Int, ruleCount: Int) {
        
        var strength = 0
        var rule = 0
        var range =  self.range(of: "[A-Z]{1,}", options: String.CompareOptions.regularExpression)
        if range != nil {
            rule += 1
            strength |= 1 << 1
        }
        
        range =  self.range(of: "[a-z]{1,}", options: String.CompareOptions.regularExpression)
        if range != nil {
            rule += 1
            strength |= 1 << 2
        }
        
        range =  self.range(of: "\\d{1,}", options: String.CompareOptions.regularExpression)
        if range != nil {
            rule += 1
            strength |= 1 << 3
        }
        
        range =  self.range(of: "\\W{1,}", options: String.CompareOptions.regularExpression)
        if range != nil {
            rule += 1
            strength |= 1 << 4
        }
        
        return (rule >= 3, strength, rule)
    }
    
    //MARK:- Time
    func utcTimeIntervalSince1970() -> Double {
        let timezone = TimeZone(identifier: "UTC")
        let locale = Locale.current //Locale(identifier: "en_US_POSIX")
        let date = NSDate(string: self, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: timezone, locale: locale)
        let diff = (date?.timeIntervalSince1970 ?? 0)
        return diff
    }
    
}


extension String {
    func getValueOf(parameter:String) -> String? {
        let query = self.components(separatedBy: "?").last
        let items = query?.components(separatedBy: "&")
        if let array = items {
            for kv in array {
                if kv.starts(with: parameter) {
                    let k_v = kv.components(separatedBy: "=")
                    return k_v.last
                }
            }
        }
        return nil
    }
}

