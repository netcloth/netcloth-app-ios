  
  
  
  
  
  
  

import Foundation

@objc class SessionCell: UITableViewCell {
    
    @IBOutlet weak var smallRemarkL: UILabel!
    @IBOutlet weak var remarkL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    @IBOutlet weak var msgL: UILabel!
    @IBOutlet weak var unreadL: UILabel!
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    
    @IBOutlet weak var doNotDisturbImageV: UIImageView?
    @IBOutlet weak var groupAvatar: GroupAvatarView?
    
    
    var smallBgColor: UIColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        smallBgColor = smallRemarkL.backgroundColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        smallRemarkL.backgroundColor = smallBgColor
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        smallRemarkL.backgroundColor = smallBgColor
    }
    
    
      
    var disbag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disbag = DisposeBag()
    }
    
    override func reloadData(data: Any) {
        guard let session = data as? CPSession else {
            return
        }
        if session.topMark == 1 {
            self.contentView.backgroundColor = UIColor(hexString: "#F5F7FA")
            self.remarkL.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            self.msgL.font = UIFont.systemFont(ofSize: 15)
            self.timeL.font = UIFont.systemFont(ofSize: 14)
        }
        else {
            self.contentView.backgroundColor = UIColor.clear
            self.remarkL.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
            self.msgL.font = UIFont.systemFont(ofSize: 14)
            self.timeL.font = UIFont.systemFont(ofSize: 13)
        }
        
        remarkL.text = session.relateContact.remark
        smallRemarkL.text = session.relateContact.remark.getSmallRemark()
        
        if session.sessionType == SessionType.group {
            groupAvatar?.isHidden = false
            smallRemarkL.isHidden = true
            smallAvatarImageV?.isHidden = true
            
            if session.groupRelateMemberNick.isEmpty {
                groupAvatar?.isHidden = true
                smallRemarkL.isHidden = false
            } else {
                groupAvatar?.reloadData(nickNames: session.groupRelateMemberNick)
            }
            
        }
        else {
            groupAvatar?.isHidden = true
            smallRemarkL.isHidden = false
            if session.relateContact.publicKey == support_account_pubkey {
                smallRemarkL.text = nil
                smallAvatarImageV?.isHidden = false
                smallAvatarImageV?.image = UIImage(named: "subscript_icon")
            } else {
                smallAvatarImageV?.isHidden = true
                
            }
        }
        
          
        if let message = session.lastMsg {
            InnerHelper.decodeOnlyText(message: message)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (r) in
                    self?.reloadMsgL(session: session)
                }).disposed(by: disbag)
        }
        
    
        
          
        unreadL.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
        unreadL.isHidden = session.unreadCount == 0
        
          
        if session.relateContact.isDoNotDisturb == true {
            unreadL.isHidden = true
            doNotDisturbImageV?.isHidden = false
            if session.unreadCount == 0 {
                doNotDisturbImageV?.image = UIImage(named: "session_disturb_bell")
            } else {
                doNotDisturbImageV?.image = UIImage(named: "session_disturb_red_bell")
            }
        }
        else {
            doNotDisturbImageV?.isHidden = true
        }
    }
    
    
    func reloadMsgL(session: CPSession) {
        
          
        timeL.text = Time.timeDesc(from: session.lastMsg?.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
        
        let msgType = session.lastMsg?.msgType
        let sessionType = session.sessionType
        
        if msgType == MessageType.groupUpdateNotice {
            let notice = session.lastMsg?.msgDecodeContent() as? String
            let content =  notice ?? ""
            
            var att1 = NSMutableAttributedString(string: "New_group_notice".localized())
            if session.groupUnreadCount <= 0 {
                att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#909399")!], range: att1.rangeOfAll())
            } else {
                att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#FF4141")!], range: att1.rangeOfAll())
            }
            
            var att2 = NSMutableAttributedString(string: content)
            att2.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#909399")!], range: att2.rangeOfAll())
            att1.append(att2)
            
            msgL.text = nil
            msgL.attributedText = att1
        }
        else {
            msgL.attributedText = nil
            if (msgType?.rawValue ?? 0 >= MessageType.inviteeUser.rawValue) {
                if let c = session.lastMsg?.msgDecodeContent() as? String {
                    var rl = c.getNoWhiteEnterString()
                    rl = rl?.replacingOccurrences(of: "#sendername#", with: smallRemarkL?.text ?? "")
                    msgL.text = rl
                }
            }
            else if sessionType == .P2P {
                if (msgType == .audio) {
                    msgL.text = "[\("Audio".localized())]"
                }
                else if (msgType == .image) {
                    msgL.text = "[\("Picture".localized())]"
                }
                else if (msgType == .text) {
                    if let c = session.lastMsg?.msgDecodeContent() as? String {
                        msgL.text = c.getNoWhiteEnterString()
                    }
                }
            }
            else if sessionType == .group {
                let senderRemark = (session.lastMsg?.senderRemark ?? session.lastMsg?.senderPubKey.getSmallRemark()) ?? ""
                if (msgType == .audio) {
                    msgL.text = "\(senderRemark): [\("Audio".localized())]"
                }
                else if (msgType == .image) {
                    msgL.text = "\(senderRemark): [\("Picture".localized())]"
                }
                else if (msgType == .text) {
                    if let c = session.lastMsg?.msgDecodeContent() as? String {
                        msgL.text = "\(senderRemark): \(c.getNoWhiteEnterString() ?? "")"
                    }
                }
            }
            else {
                msgL.text = "Msg_Recieve_Unknown".localized()
            }
            
        }
    }
}

