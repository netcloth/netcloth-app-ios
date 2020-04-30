//
//  TextChatCell.swift
//  chat
//
//  Created by Grand on 2019/8/1.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

@objc class TextChatCell: ChatCommonCell {
    
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
    @IBOutlet weak var msgContentTextView: MsgChatTextView?
    
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
    
    var dataMsg: CPMessage?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarBtn?.addTarget(self, action: #selector(onTapAvatar), for: .touchUpInside)
        self.smallAvatarImageV?.layer.borderWidth = 1.0
        self.smallAvatarImageV?.layer.borderColor = UIColor(hexString: Color.gray_d8)!.cgColor
        self.smallAvatarImageV?.contentMode = .scaleAspectFill
        
        msgBgImgView?.layer.cornerRadius = 20
    }
    @objc func onTapAvatar() {
        if let d = dataMsg {
            delegate?.onTapAvatar?(pubkey: d.senderPubKey)
        }
    }
    
    override func onTapCell() {
        
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
        
        msgContentL?.text = msg.msgDecodeContent() as? String
        msgContentTextView?.text = msg.msgDecodeContent() as? String
        
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
        
        msgContentL?.text = msg.msgDecodeContent() as? String
        msgContentTextView?.text = msg.msgDecodeContent() as? String
        
        smallRemarkL?.text = RoomStatus.remark?.getSmallRemark()
        let color = msg.senderPubKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        

        if let a =  msg.senderPubKey.isAssistHelper(),
            a.avatar.isEmpty == false {
            smallRemarkL?.text = nil
            smallAvatarImageV?.isHidden = false
            smallAvatarImageV?.nc_typeImage(url: a.avatar)
            smallRemarkL?.isHidden = true
        } else {
            smallAvatarImageV?.isHidden = true
            smallRemarkL?.isHidden = false
        }
    }
    
    //MARK:- Interface
    override func msgContentView() -> UIView? {
        return self.msgContentTextView
    }

}
