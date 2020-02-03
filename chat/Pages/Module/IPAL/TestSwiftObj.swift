  
  
  
  
  
  
  

import UIKit

class TestSwiftObj: NSObject {
    
    static func testPubkey() {
        let pubkey = "04652ab1baf227b596eed8523578b25bc22e6ff13ac597dc5d1f28ac9804c4aa6cc7f38b292d3d155638a2c426ed737b86e11f6428b8fec1451c017ba0fd7c9676"
        let compressed = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: pubkey)
        
        if let c = compressed {
            let unc = OC_Chat_Plugin_Bridge.unCompressedHexStrPubkey(ofCompressHexPubkey:c)
            print("decode " + (unc ?? "error"))
        }
    }
    
    static func pushMsg() {
        PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "ssss")
    }
    
}
