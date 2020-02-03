  
  
  
  
  
  
  

import UIKit

class GroupListVC: IndexRankVC {
    
    var groupCount: Int = 0 {
        didSet {
            let count = self.groupCount
            if count == 0 {
                self.title = "Group Chat".localized()
            } else {
                self.title = "\("Group Chat".localized())(\(count))"
            }
        }
    }
    
    override func requestData() {
        CPContactHelper.getGroupListContacts{ [weak self]  (contacts) in
            self?.groupCount = contacts?.count ?? 0
            self?.fillData(contacts)
        }
    }
    
    override func onTap(row: IndexPath, model: CPContact?) {
        
        #if DEBUG
        if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
            vc.chatContact = model!
            Router.pushViewController(vc: vc)
        }
        return
        #endif
        
          
        if let contact = model,
            contact.sessionId > 0,
            contact.decodePrivateKey().count > 10 {
            if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
                vc.chatContact = contact
                Router.pushViewController(vc: vc)
            }
        }
        else {
            Toast.show(msg: "System error".localized())
        }
    }
}

