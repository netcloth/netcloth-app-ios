







import Foundation

@objc class SessionCell: UITableViewCell {
    
    @IBOutlet weak var smallRemarkL: UILabel!
    @IBOutlet weak var remarkL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var msgL: UILabel!
    @IBOutlet weak var unreadL: UILabel!
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    
    override func reloadData(data: Any) {
        
        if let session = data as? CPSession {
            
            if session.topMark == 1 {
                self.contentView.backgroundColor = UIColor(hexString: "#F5F7FA")
                self.remarkL.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
                self.msgL.font = UIFont.systemFont(ofSize: 15)
                self.timeL.font = UIFont.systemFont(ofSize: 14)
            }
            else {
                self.contentView.backgroundColor = UIColor.white
                self.remarkL.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
                self.msgL.font = UIFont.systemFont(ofSize: 14)
                self.timeL.font = UIFont.systemFont(ofSize: 13)
            }
            
            remarkL.text = session.relateContact.remark
            smallRemarkL.text = session.relateContact.remark.getSmallRemark()
            
            if session.relateContact.publicKey == support_account_pubkey {
                smallRemarkL.text = nil
                smallAvatarImageV?.isHidden = false
                smallAvatarImageV?.image = UIImage(named: "subscript_icon")
            } else {
                smallAvatarImageV?.isHidden = true
            }
            
            
            if (session.lastMsg?.msgType == .audio) {
                msgL.text = "[\("Audio".localized())]"
            }
            else if (session.lastMsg?.msgType == .image) {
                msgL.text = "[\("Picture".localized())]"
            }
            else if (session.lastMsg?.msgType == .text) {
                if let c = session.lastMsg?.msgDecodeContent() as? String {
                    msgL.text = c.getNoWhiteEnterString()
                }
            }
            else {
                msgL.text = "[你收到了一条未知消息]"
            }
            

            timeL.text = Time.timeDesc(from: session.lastMsg?.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
            

            unreadL.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
            unreadL.isHidden = session.unreadCount == 0
        }
    }
}
