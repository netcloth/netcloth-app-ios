  
  
  
  
  
  
  

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
    
      
    @IBOutlet weak var avatarBtn: UIButton?
    
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    
    var dataMsg: CPMessage?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarBtn?.addTarget(self, action: #selector(onTapAvatar), for: .touchUpInside)
    }
    @objc func onTapAvatar() {
        if let d = dataMsg {
            delegate?.onTapAvatar?(pubkey: d.senderPubKey)
        }
    }
    
    override func onTapCell() {
        guard let content = self.msgContentL?.text else {
            return
        }
        var reg = "[a-zA-z]+:  
        let range =  content.range(of: reg, options: String.CompareOptions.regularExpression)
        if range != nil {
            let suburl = String(content[range!])
            if suburl.lowercased().hasPrefix("http") {
                let browser = GrandBrowserVC()
                browser.loadUrl(string: suburl)
                Router.pushViewController(vc: browser)
            }
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
    }
    
      

    
    func updateSelf(msg: CPMessage) {
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
        var img = UIImage(named: "蓝色-聊天")
        img = img?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
        msgBgImgView?.image = img
        
        if msg.msgType == MessageType.groupUpdateNotice {
            let notice = msg.msgDecodeContent() as? String
            let content = "New_group_notice".localized() + (notice ?? "")
            msgContentL?.text = content
        } else {
            msgContentL?.text = msg.msgDecodeContent() as? String
        }
        
        smallRemarkL?.text = (CPAccountHelper.loginUser()?.accountName ?? "").getSmallRemark()
        
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
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
        var img = UIImage(named: "灰色-聊天")
        img = img?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
        msgBgImgView?.image = img
        
        
        if msg.msgType == MessageType.groupUpdateNotice {
            let notice = msg.msgDecodeContent() as? String
            let content = "New_group_notice".localized() + (notice ?? "")
            msgContentL?.text = content
        } else {
            msgContentL?.text = msg.msgDecodeContent() as? String
        }
        
        var sendRemark = msg.senderRemark
        smallRemarkL?.text = sendRemark.getSmallRemark()
        LgroupNick?.text = sendRemark

        if msg.senderPubKey == support_account_pubkey {
            smallRemarkL?.text = nil
            smallAvatarImageV?.isHidden = false
            smallAvatarImageV?.image = UIImage(named: "subscript_icon")
        } else {
            smallAvatarImageV?.isHidden = true
        }
    }
    
      
    override func msgContentView() -> UIView? {
        return self.msgContentL
    }
}
