  
  
  
  
  
  
  

import Foundation

extension CPChainClaim {
    func calStates() -> (dotName:String, desc: String, color: UIColor)
    {
        if self.chain_status == 1 {
            return ("dot_green","history_Success".localized(),UIColor(hexString: "#5ABB27")!)
        } else if self.chain_status == 2 {
            return ("dot_yellow","history_Fail".localized(),UIColor(hexString: "#F77221")!)
        } else {
            return ("dot_blue","history_Pending".localized(),UIColor(hexString: "#3D7EFF")!)
        }
    }
}


var key_height = ""
var key_isAudioPlaying = ""
extension CPMessage  {
    var cellHeigth: CGFloat {
        set {
            objc_setAssociatedObject(self, &key_height, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_height) as? CGFloat {
                return n
            }
            return 0
        }
    }
    
    var isAudioPlaying: Bool {
        set {
            objc_setAssociatedObject(self, &key_isAudioPlaying, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_isAudioPlaying) as? Bool {
                return n
            }
            return false
        }
    }
}

var key_contact_read = ""
var key_contact_selected = ""
var key_pinyin_index = ""

extension CPContact {
    var haveReadNewFriends: Bool {
        set {
            objc_setAssociatedObject(self, &key_contact_read, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_contact_read) as? Bool {
                return n
            }
            return false
        }
    }
    
    var isSelected: Bool {
        set {
            objc_setAssociatedObject(self, &key_contact_selected, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_contact_selected) as? Bool {
                return n
            }
            return false
        }
    }
    
    var pinyinIndex: String {
        set {
            objc_setAssociatedObject(self, &key_pinyin_index, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_pinyin_index) as? String {
                return n
            }
            return ""
        }
    }
}


var key_member_fake = ""
extension CPGroupMember {
    var fakePlaceType: Int {
        set {
            objc_setAssociatedObject(self, &key_member_fake, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_member_fake) as? Int {
                return n
            }
            return 0
        }
    }
    
    var isSelected: Bool {
        set {
            objc_setAssociatedObject(self, &key_contact_selected, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_contact_selected) as? Bool {
                return n
            }
            return false
        }
    }
    
    var pinyinIndex: String {
        set {
            objc_setAssociatedObject(self, &key_pinyin_index, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_pinyin_index) as? String {
                return n
            }
            return ""
        }
    }
}
