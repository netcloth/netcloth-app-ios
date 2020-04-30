//
//  File.swift
//  chat
//
//  Created by Grand on 2019/8/12.
//  Copyright © 2019 netcloth. All rights reserved.
//

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
//        smallBgColor = smallRemarkL.backgroundColor
        configUI()
    }
    
    fileprivate func configUI() {
        
        self.smallAvatarImageV?.layer.borderWidth = 1.0
        self.smallAvatarImageV?.layer.borderColor = UIColor(hexString: Color.gray_d8)!.cgColor
        self.smallAvatarImageV?.contentMode = .scaleAspectFill
        
        self.remarkL?.font = UIFont.systemFont(ofSize: FontSize.normal, weight: UIFont.Weight.medium)
        self.msgL?.font = UIFont.systemFont(ofSize: FontSize.small)
        self.timeL?.font = UIFont.systemFont(ofSize: FontSize.little)
        self.unreadL?.font = UIFont.systemFont(ofSize: FontSize.least)
        
        self.remarkL?.textColor = UIColor(hexString: Color.black)
        self.msgL?.textColor = UIColor(hexString: Color.gray)
        self.timeL?.textColor = UIColor(hexString: Color.gray_bf)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        smallRemarkL.backgroundColor = smallBgColor
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
//        smallRemarkL.backgroundColor = smallBgColor
    }
    
    
    //MARK:- Reload
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
            self.contentView.backgroundColor = UIColor(hexString: Color.gray_f5)
        }
        else {
            self.contentView.backgroundColor = UIColor.clear
        }
        
        remarkL.text = session.relateContact.remark
        smallRemarkL.text = session.relateContact.remark.getSmallRemark()
        
        let color = session.relateContact.publicKey.randomColor()
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        if session.sessionType == SessionType.group {
            groupAvatar?.isHidden = false
            smallRemarkL.isHidden = true
            smallAvatarImageV?.isHidden = true
            
            if session.groupRelateMember.isEmpty {
                groupAvatar?.isHidden = true
                smallRemarkL.isHidden = false
            } else {
                groupAvatar?.reloadData(members: session.groupRelateMember)
            }
            
        }
        else {
            groupAvatar?.isHidden = true
            smallRemarkL.isHidden = false
            if let a = session.relateContact.publicKey.isAssistHelper(), a.avatar.isEmpty == false {
                smallRemarkL.text = nil
                smallAvatarImageV?.isHidden = false
                smallAvatarImageV?.nc_typeImage(url: a.avatar)
                smallRemarkL?.isHidden = true
            } else {
                smallAvatarImageV?.isHidden = true
                smallRemarkL?.isHidden = false
            }
        }
        
        //刷新内容
        if let message = session.lastMsg {
            InnerHelper.decodeOnlyText(message: message)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (r) in
                    self?.reloadMsgL(session: session)
                }).disposed(by: disbag)
        }
        else {
            self.cleanMsgL(session: session)
        }
        
    
        
        //unread
        unreadL.text = session.unreadCount > 99 ? "99+" : "\(session.unreadCount)"
        unreadL.isHidden = session.unreadCount == 0
        
        //disturb
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
    
    
    func cleanMsgL(session: CPSession) {
        timeL.text = Time.timeDesc(from: session.lastMsg?.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
        msgL.text = nil
        msgL.attributedText = nil
    }
    
    //MARK:-  load Msg
    func reloadMsgL(session: CPSession) {
        //time
        timeL.text = Time.timeDesc(from: session.lastMsg?.createTime ?? NSDate().timeIntervalSince1970, includeH_M: false)
        
        let msgType = session.lastMsg?.msgType
        let sessionType = session.sessionType
        let atType = session.atRelateMsg?.useway
        
        if msgType == MessageType.groupUpdateNotice {
            let att1 = getNoticeTipOf(session: session)
            msgL.text = nil
            msgL.attributedText = att1
        }
        else if atType == MessageUseWay.atAll || atType == MessageUseWay.atMe {
            let att1 = getAtTipOf(session: session)
            msgL.text = nil
            msgL.attributedText = att1
        }
        else {
            let t1 =  getMsgTipOf(session: session)
            msgL.attributedText = nil
            msgL.text = t1
        }
    }
    
    //MARK:- Msg Helper
    fileprivate func getMsgTipOf(session: CPSession) -> String? {
        let msgType = session.lastMsg?.msgType
        let sessionType = session.sessionType
        let atType = session.atRelateMsg?.useway
        if (msgType?.rawValue ?? 0 >= MessageType.inviteeUser.rawValue) {
            if let c = session.lastMsg?.msgDecodeContent() as? String {
                var rl = c.getNoWhiteEnterString()
                rl = rl?.replacingOccurrences(of: "#sendername#", with: smallRemarkL?.text ?? "")
                return rl
            }
        }
        else if sessionType == .P2P {
            if (msgType == .audio) {
                return "[\("Audio".localized())]"
            }
            else if (msgType == .image) {
                return "[\("Picture".localized())]"
            }
            else if (msgType == .text) {
                if let c = session.lastMsg?.msgDecodeContent() as? String {
                    return  c.getNoWhiteEnterString()
                }
            }
        }
        else if sessionType == .group {
            let senderRemark = (session.lastMsg?.senderRemark ?? session.lastMsg?.senderPubKey.getSmallRemark()) ?? ""
            if (msgType == .audio) {
                return  "\(senderRemark): [\("Audio".localized())]"
            }
            else if (msgType == .image) {
                return  "\(senderRemark): [\("Picture".localized())]"
            }
            else if (msgType == .text) {
                if let c = session.lastMsg?.msgDecodeContent() as? String {
                    return  "\(senderRemark): \(c.getNoWhiteEnterString() ?? "")"
                }
            }
        }
        else {
            return  "Msg_Recieve_Unknown".localized()
        }
        return ""
    }
    
    fileprivate func getNoticeTipOf(session: CPSession) -> NSAttributedString? {
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
        return att1
    }
    
    fileprivate func getAtTipOf(session: CPSession) -> NSAttributedString? {
        let msgType = session.lastMsg?.msgType
        let sessionType = session.sessionType
        let atType = session.atRelateMsg?.useway
        
        var content = ""
        let senderRemark = (session.lastMsg?.senderRemark ?? session.lastMsg?.senderPubKey.getSmallRemark()) ?? ""
        if (msgType == .audio) {
            content = "\(senderRemark): [\("Audio".localized())]"
        }
        else if (msgType == .image) {
            content = "\(senderRemark): [\("Picture".localized())]"
        }
        else if (msgType == .text) {
            if let c = session.lastMsg?.msgDecodeContent() as? String {
                content = "\(senderRemark): \(c.getNoWhiteEnterString() ?? "")"
            }
        }
        
        var att1 = NSMutableAttributedString(string: "@Msg_notice".localized())
        if session.groupUnreadCount <= 0 {
            att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#909399")!], range: att1.rangeOfAll())
        } else {
            att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#FF4141")!], range: att1.rangeOfAll())
        }
        
        var att2 = NSMutableAttributedString(string: content)
        att2.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#909399")!], range: att2.rangeOfAll())
        att1.append(att2)
        return att1
    }
    
}

