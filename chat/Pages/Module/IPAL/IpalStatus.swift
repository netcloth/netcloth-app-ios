  
  
  
  
  
  
  

import UIKit

typealias EnterPoint = [IPALNode]

  
class IpalStatus: NSObject {
      
    @objc dynamic var oldCIpal: IPALNode?
    
    var isSeedError: Bool?
    
    @objc dynamic var currentCIpal: IPALNode? {
        willSet {
            oldCIpal = self.currentCIpal
            isSeedError = false
        }
    }
}
