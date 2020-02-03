  
  
  
  
  
  
  

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
}
