







import UIKit


class FakeStrangerSession: CPSession {}
class FakeNotifySession: CPSession {}
class FakeRecommendedSession: CPSession {}


@objc class PatchSessionCell: UITableViewCell {
    @IBOutlet weak var tagL: UILabel?
    @IBOutlet weak var unreadL: UILabel?
    @IBOutlet weak var timeL: UILabel?
    
    override func reloadData(data: Any) {
        
        guard let session = data as? CPSession  else {
            return
        }
        
        if session.topMark == 1 {
            self.contentView.backgroundColor = UIColor(hexString: Color.gray_f5)
            self.tagL?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            self.timeL?.font = UIFont.systemFont(ofSize: 14)
        }
        else {
            self.contentView.backgroundColor = UIColor.clear
            self.tagL?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
            self.timeL?.font = UIFont.systemFont(ofSize: 13)
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
        else if session is FakeRecommendedSession {
            tagL?.text = "Group recommendation".localized()
            unreadL?.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
            unreadL?.isHidden = session.unreadCount == 0
            
            timeL?.text = Time.timeDesc(from: session.updateTime , includeH_M: false)
        }
    }
}
