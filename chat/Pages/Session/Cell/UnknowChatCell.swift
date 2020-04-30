







import Foundation

@objc class UnknowChatCell: ChatCommonCell {
    
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
    
    @IBOutlet weak var avatarBtn: UIButton?
    
    
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
    
    
    var isHideTimeL: Bool = true {
        didSet {
            createTimeL?.isHidden = self.isHideTimeL
            self.avatarTop?.constant = self.isHideTimeL ? 10 : 47
        }
    }
    
    
    override func msgContentView() -> UIView? {
        return self.msgContentL
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
        



        msgBgImgView?.backgroundColor = UIColor(hexString: Color.blue)
        
        
        msgContentL?.text = "[你发送了一条未知消息]"
        
        
        smallRemarkL?.text = (CPAccountHelper.loginUser()?.accountName ?? "").getSmallRemark()
        let color = CPAccountHelper.loginUser()?.publicKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        sendStateImgV?.isHidden = !(msg.toServerState == 1)
        sendErrorBtn?.isHidden = !(msg.toServerState == 2)
    }
    
    func updateOthers(msg: CPMessage) {
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
        



        msgBgImgView?.backgroundColor = UIColor.white
        
        
        msgContentL?.text = "Msg_Recieve_Unknown".localized()
        
        
        if msg.isGroupChat {
            smallRemarkL?.text = msg.senderRemark.getSmallRemark()
        }
        else {
            smallRemarkL?.text = RoomStatus.remark?.getSmallRemark()
        }
        let color = msg.senderPubKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
    }
}
