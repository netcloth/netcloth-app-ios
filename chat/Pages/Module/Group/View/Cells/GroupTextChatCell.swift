//
//  TextChatCell.swift
//  chat
//
//  Created by Grand on 2019/8/1.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

@objc class GroupTextChatCell: ChatCommonCell {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    @IBOutlet weak var sendStateIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var sendErrorBtn: UIButton?
    @IBAction func onRetrySendAction() {
        if let d = dataMsg {
            delegate?.onRetrySendMsg?(d.msgId)
        }
    }
    
    @IBOutlet weak var sendStateImgV: UIImageView?

    @IBOutlet weak var smallRemarkL: UILabel?
    
    @IBOutlet weak var msgBgImgView: UIImageView?
    @IBOutlet weak var msgContentL: UILabel?
    
    @IBOutlet weak var createTimeL: UILabel?
    @IBOutlet weak var avatarTop: NSLayoutConstraint?
    var isHideTimeL: Bool = true {
        didSet {
            createTimeL?.isHidden = self.isHideTimeL
            self.avatarTop?.constant = self.isHideTimeL ? 10 : 47
        }
    }
    
    /// avatar tap
    @IBOutlet weak var avatarBtn: UIButton?
    
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    @IBOutlet weak var msgContentTextView: MsgChatTextView?
    
    var dataMsg: CPMessage?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarBtn?.addTarget(self, action: #selector(onTapAvatar), for: .touchUpInside)
        
        if let avBtn = self.avatarBtn {
            let lpr = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressAvatar(_:)))
            lpr.minimumPressDuration = 1.0
            avBtn.addGestureRecognizer(lpr)
        }
    }
    
    @objc func onTapAvatar() {
        if let d = dataMsg {
            delegate?.onTapAvatar?(pubkey: d.senderPubKey)
        }
    }
    
    @objc func onLongPressAvatar(_ gst: UILongPressGestureRecognizer) {
        if let d = dataMsg,
            gst.state == .began {
            delegate?.onLongPressAvatar?(pubkey: d.senderPubKey, senderName: d.senderRemark)
        }
    }
    
    override func reloadData(data: Any) {
        guard let msg = data as? CPMessage else {
            return
        }
        dataMsg = msg
        if msg.senderPubKey == CPAccountHelper.loginUser()?.publicKey {
            updateSelf(msg: msg)
        } else {
            updateOthers(msg: msg)
        }
        
        //identify
        self.LgroupNick?.isHidden = false
        self.LgroupMasterIden?.isHidden = true
        if let masterPubkey = self.viewController?.roomService?.groupMasterPubkey,
            msg.senderPubKey == masterPubkey {
            self.LgroupMasterIden?.isHidden = false
        }
    }
    
    //MARK:- Reload

    
    func updateSelf(msg: CPMessage) {
        let linkColor = UIColor.white
        self.msgContentTextView?.linkColor = linkColor
        self.msgContentTextView?.linkTextAttributes = [.foregroundColor: linkColor]
        self.msgContentTextView?.tintColor = linkColor
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
//        var img = UIImage(named: "蓝色-聊天")
//        img = img?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
//        msgBgImgView?.image = img
        msgBgImgView?.backgroundColor = UIColor(hexString: Color.blue)
        
        
        var contentStr = ""
        if msg.msgType == MessageType.groupUpdateNotice {
            let notice = msg.msgDecodeContent() as? String
            let content = "New_group_notice".localized() + (notice ?? "")
            contentStr = content
        } else {
            contentStr = msg.msgDecodeContent() as? String ?? ""
        }
        msgContentL?.text = contentStr
        msgContentTextView?.text = contentStr
        
        smallRemarkL?.text = (CPAccountHelper.loginUser()?.accountName ?? "").getSmallRemark()
        let color = CPAccountHelper.loginUser()?.publicKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        sendStateImgV?.isHidden = !(msg.toServerState == 1)
        sendErrorBtn?.isHidden = !(msg.toServerState == 2)
        
        let expect = NSDate().timeIntervalSince1970 - 180
        if msg.toServerState == 0, msg.createTime > expect  {
            sendStateIndicator?.isHidden = false;
            sendStateIndicator?.startAnimating()
        } else {
            sendStateIndicator?.isHidden = true;
            sendStateIndicator?.stopAnimating()
        }
    }
    
    func updateOthers(msg: CPMessage) {
        
        self.msgContentTextView?.linkColor = UIColor(hexString: Color.blue)!
        self.msgContentTextView?.linkTextAttributes = [.foregroundColor: UIColor(hexString: Color.blue)!]
        self.msgContentTextView?.tintColor = UIColor(hexString: Color.blue)
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
//        var img = UIImage(named: "灰色-聊天")
//        img = img?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
//        msgBgImgView?.image = img
        msgBgImgView?.backgroundColor = UIColor.white
        
        var contentStr = ""
        if msg.msgType == MessageType.groupUpdateNotice {
            let notice = msg.msgDecodeContent() as? String
            let content = "New_group_notice".localized() + (notice ?? "")
            contentStr = content
        } else {
            contentStr = msg.msgDecodeContent() as? String ?? ""
        }
        msgContentL?.text = contentStr
        msgContentTextView?.text = contentStr
        
        var sendRemark = msg.senderRemark
        smallRemarkL?.text = sendRemark.getSmallRemark()
        LgroupNick?.text = sendRemark
        
        let color = msg.senderPubKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        smallAvatarImageV?.isHidden = true
    }
    
    //MARK:- Interface
    override func msgContentView() -> UIView? {
        return self.msgContentTextView
    }
}
