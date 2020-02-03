  
  
  
  
  
  
  

import UIKit

@objc class PatchSessionCell: UITableViewCell {
    @IBOutlet weak var tagL: UILabel?
    @IBOutlet weak var unreadL: UILabel?
    @IBOutlet weak var timeL: UILabel?
    
    override func reloadData(data: Any) {
        
        guard let session = data as? CPSession  else {
            return
        }
        
        if session is FakeStrangerSession {
            tagL?.text = "Stranger Messages".localized()
            unreadL?.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
            unreadL?.isHidden = session.unreadCount == 0
              
            timeL?.text = Time.timeDesc(from: session.lastMsg?.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
        }
        else if session is FakeNotifySession {
            tagL?.text = "Group Notices".localized()
            unreadL?.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
            unreadL?.isHidden = session.unreadCount == 0
              
            timeL?.text = Time.timeDesc(from: session.updateTime , includeH_M: false)
        }
    }
}
