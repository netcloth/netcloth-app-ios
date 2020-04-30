







import UIKit

@objc class NotifySessionPreviewCell: UITableViewCell {

    @IBOutlet weak var groupAvatar: GroupAvatarView?
    
    @IBOutlet weak var smallRemarkL: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    
    @IBOutlet weak var msgL: UILabel?
    
    @IBOutlet weak var timeL: UILabel?
    @IBOutlet weak var unreadL: UILabel?
    
    
    override func reloadData(data: Any) {
        
        if let session = data as? CPGroupNotifySession {
            _reloadData(session)
        }
    }
    
    fileprivate func _reloadData(_ session: CPGroupNotifySession) {
        remarkL?.text = session.relateContact.remark
        smallRemarkL?.text = session.relateContact.remark.getSmallRemark()
        let color = session.relateContact.publicKey.randomColor()
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        if session.groupRelateMember.isEmpty == false {
            groupAvatar?.isHidden = false
            smallRemarkL?.isHidden = true
            groupAvatar?.reloadData(members: session.groupRelateMember)
            
        } else {
            groupAvatar?.isHidden = true
            smallRemarkL?.isHidden = false
        }
        
        
        msgL?.text = "[\("Group Confirmation".localized())]"
        if session.unreadCount == 0 {
            msgL?.textColor = UIColor(hexString: Color.gray_90)
        } else {
            msgL?.textColor = UIColor(hexString: Color.red)
        }
        
        
        
        timeL?.text = Time.timeDesc(from: session.lastNotice?.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
        
        
        unreadL?.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
        unreadL?.isHidden = session.unreadCount == 0
    }
}
