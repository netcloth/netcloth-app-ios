







import UIKit

class TestSwiftObj: NSObject {
    
    static func pushMsg() {
        PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "ssss")
    }
    
}
