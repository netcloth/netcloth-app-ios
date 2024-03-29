







import UIKit

class GroupAudioChatCell: ChatCommonCell {
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    
    @IBOutlet weak var sendStateIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var sendErrorBtn: UIButton? 
    @IBAction func onRetrySendAction() {
        if let d = dataMsg {
            delegate?.onRetrySendMsg?(d.msgId)
        }
    }
    
    @IBOutlet weak var smallRemarkL: UILabel?
    
    @IBOutlet weak var msgBgImgView: UIImageView?
    @IBOutlet weak var msgContentL: UILabel?
    @IBOutlet weak var audioIcon: UIImageView?
    
    @IBOutlet weak var bgImgVWidth: NSLayoutConstraint?
    @IBOutlet weak var readTipsImg: UIImageView? 
    @IBOutlet weak var sendStateImgV: UIImageView? 
    
    private var cpMsg: CPMessage?
    
    @IBOutlet weak var createTimeL: UILabel?
    @IBOutlet weak var avatarTop: NSLayoutConstraint?
    var isHideTimeL: Bool = true {
        didSet {
            createTimeL?.isHidden = self.isHideTimeL
            self.avatarTop?.constant = self.isHideTimeL ? 10 : 47
        }
    }
    
    
    @IBOutlet weak var avatarBtn: UIButton?
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
    
    
    override func msgContentView() -> UIView? {
        return self.msgContentL
    }
    
    
    override func onTapCell() {
        if let m = cpMsg {
            
            if m.isAudioPlaying == true {
                
                m.isAudioPlaying = false
                SRRecordingAudioPlayerManager.shared()?.stop()
                
            } else {
                
                if let last = lastPlayingMsg {
                    last.isAudioPlaying = false
                }
                lastPlayingMsg = m
                
                m.isAudioPlaying = true
                self.startAudioAnimate()
                let a = m.msgDecodeContent()
                let d = a as? Data
                SRRecordingAudioPlayerManager.shared()?.play(d, with: {  [weak self] (res, msg) in
                    m.isAudioPlaying = false
                    if m == self?.cpMsg {
                        self?.stopAudioAnimate()
                    }
                })
                
                CPGroupManagerHelper.setReadOfMessage(m.msgId, complete: nil)
                m.audioRead = true
                refreshAudioTips()
            }
        }
    }
    
    override func reloadData(data: Any) {
        guard let msg = data as? CPMessage else {
            return
        }
        cpMsg = msg
        dataMsg = msg
        if msg.senderPubKey == CPAccountHelper.loginUser()?.publicKey {
            updateSelf(msg: msg)
        } else {
            updateOthers(msg: msg)
        }
        
        
        if msg.isAudioPlaying == true {
            self.startAudioAnimate()
            SRRecordingAudioPlayerManager.shared()?.call = { [weak self] (res, message) in
                msg.isAudioPlaying = false
                if self?.cpMsg == msg {
                    self?.stopAudioAnimate()
                }
            }
        }
        else {
            self.stopAudioAnimate()
        }
        
        
        self.LgroupNick?.isHidden = false
        self.LgroupMasterIden?.isHidden = true
        if let masterPubkey = self.viewController?.roomService?.groupMasterPubkey,
            msg.senderPubKey == masterPubkey {
            self.LgroupMasterIden?.isHidden = false
        }
    }
    
    
    func updateSelf(msg: CPMessage) {
        
        sendStateImgV?.isHidden = !(msg.toServerState == 1)
        sendErrorBtn?.isHidden = !(msg.toServerState == 2)
        
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
        



        msgBgImgView?.backgroundColor = UIColor(hexString: Color.blue)
        
        
        var images:[UIImage] = []
        images.append(UIImage(named: "蓝色-1点")!)
        images.append(UIImage(named: "蓝色-2点")!)
        images.append(UIImage(named: "蓝色-3点")!)
        self.audioIcon?.animationImages = images
        self.audioIcon?.animationDuration = 2
        self.audioIcon?.image = UIImage(named: "蓝色-3点")
        
        smallRemarkL?.text = (CPAccountHelper.loginUser()?.accountName ?? "").getSmallRemark()
        let color = CPAccountHelper.loginUser()?.publicKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        
        
        self.msgContentL?.text = "\(min(msg.audioTimes,60))\""
        self.bgImgVWidth?.constant = getWidthOfTime(msg.audioTimes)
        
        
        refreshAudioTips()
        
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
        



        msgBgImgView?.backgroundColor = UIColor.white
        
        var images:[UIImage] = []
        images.append(UIImage(named: "灰色-1点")!)
        images.append(UIImage(named: "灰色-2点")!)
        images.append(UIImage(named: "灰色-3点")!)
        self.audioIcon?.animationImages = images
        self.audioIcon?.animationDuration = 2
        self.audioIcon?.image = UIImage(named: "灰色-3点")
        
        var sendRemark = msg.senderRemark
        smallRemarkL?.text = sendRemark.getSmallRemark()
        let color = msg.senderPubKey.randomColor() ?? RelateDefaultColor
        smallRemarkL?.backgroundColor = UIColor(hexString: color)
        LgroupNick?.text = sendRemark
        
        self.msgContentL?.text = "\(min(msg.audioTimes,60))\""
        self.bgImgVWidth?.constant = getWidthOfTime(msg.audioTimes)
        
        refreshAudioTips()
        
        if let assist = msg.senderPubKey.isAssistHelper() {
            smallRemarkL?.text = nil
            smallAvatarImageV?.isHidden = false
            smallAvatarImageV?.image = UIImage(named: "subscript_icon")
        } else {
            smallAvatarImageV?.isHidden = true
        }
    }
    
    
    
    func refreshAudioTips() {
        self.readTipsImg?.image = UIImage(named: "红点")
        self.readTipsImg?.isHidden = self.cpMsg?.audioRead ?? true
    }
    
    func getWidthOfTime(_ t:Int) -> CGFloat {
        let max: Int = 200
        let min: Int = 70
        let t_min: Int = 2
        let t_max: Int = 60
        
        let diff = max - min
        let t_diff: Double = fabs(Double(t - t_min)) / Double(t_max)
        
        let r: Double = ceil(Double(min) + Double(diff) * t_diff)
        return CGFloat(r)
    }
    
    func startAudioAnimate() {
        if self.audioIcon?.isAnimating == false {
            self.audioIcon?.startAnimating()
        }
    }
    
    func stopAudioAnimate() {
        self.audioIcon?.stopAnimating()
    }
}
