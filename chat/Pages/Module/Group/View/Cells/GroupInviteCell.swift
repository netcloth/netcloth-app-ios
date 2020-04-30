







import UIKit

class GroupInviteCell: ChatCommonCell {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    @IBOutlet weak var groupNameL: UILabel?
    @IBOutlet weak var groupTitleL: UILabel?
    
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
        self.smallAvatarImageV?.layer.borderWidth = 1.0
        self.smallAvatarImageV?.layer.borderColor = UIColor(hexString: Color.gray_d8)!.cgColor
        self.smallAvatarImageV?.contentMode = .scaleAspectFill
        groupNameL?.backgroundColor = UIColor(hexString: Color.blue)
    }
    @objc func onTapAvatar() {
        if let d = dataMsg {
            delegate?.onTapAvatar?(pubkey: d.senderPubKey)
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
        
        msgBgImgView?.backgroundColor = UIColor.white
        
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
        
        groupTitleL?.text = "Group_Invit_Msg_Title".localized()
        groupNameL?.text = msg.groupName.getSmallRemark()
        
        var rl = msg.msgDecodeContent() as? String
        rl = rl?.replacingOccurrences(of: "#sendername#", with: smallRemarkL?.text ?? "")
        
        msgContentL?.text = rl
    }
    
    func updateOthers(msg: CPMessage) {
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        



        msgBgImgView?.backgroundColor = UIColor.white
        
        
        var sendRemark = RoomStatus.remark ?? ""
        smallRemarkL?.text = sendRemark.getSmallRemark()
        let color = msg.senderPubKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        
        if let assist =  msg.senderPubKey.isAssistHelper(), assist.avatar.isEmpty == false {
            smallRemarkL?.text = nil
            smallAvatarImageV?.isHidden = false
            smallAvatarImageV?.nc_typeImage(url: assist.avatar)
            smallRemarkL?.isHidden = true
        } else {
            smallAvatarImageV?.isHidden = true
            smallRemarkL?.isHidden = false
        }
        
        
        groupTitleL?.text = "Group_Invit_Msg_Title".localized()
        groupNameL?.text = msg.groupName.getSmallRemark()
        
        var rl = msg.msgDecodeContent() as? String
        rl = rl?.replacingOccurrences(of: "#sendername#", with: smallRemarkL?.text ?? "")
        
        msgContentL?.text = rl
    }
    
    
    override func msgContentView() -> UIView? {
        return self.groupTitleL
    }
    
    override func onTapCell() {
        if let d = dataMsg, d.msgType == .inviteeUser {
            if let vc = R.loadSB(name: "GroupInviteDetailVC", iden: "GroupInviteDetailVC") as?  GroupInviteDetailVC {
                vc.msg = d
                Router.pushViewController(vc: vc)
            }
        }
    }
}
