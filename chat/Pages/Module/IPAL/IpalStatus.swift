







import UIKit

typealias EnterPoint = [IPALNode]


class IpalStatus: NSObject {

    @objc dynamic var oldCIpal: IPALNode?
    
    @objc dynamic var currentCIpal: IPALNode? {
        
        willSet {
            oldCIpal = self.currentCIpal
        }
    }
}
