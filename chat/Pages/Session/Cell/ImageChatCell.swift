







import UIKit

class ImageChatCell: ChatCommonCell {
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    
    @IBOutlet weak var stateIndicator: UIActivityIndicatorView?
    @IBOutlet weak var stateIndicatorContainer: UIView?
    
    @IBOutlet weak var pictureImage: UIImageView?
    @IBOutlet weak var imageWidth: NSLayoutConstraint?
    @IBOutlet weak var imageHeight: NSLayoutConstraint?
    
    @IBOutlet weak var sendErrorBtn: UIButton?
    @IBAction func onRetrySendAction() {
        if let d = dataMsg {
            delegate?.onRetrySendMsg?(d.msgId)
        }
    }
    
    @IBOutlet weak var sendStateImgV: UIImageView?

    @IBOutlet weak var smallRemarkL: UILabel?
    @IBOutlet weak var msgBgImgView: UIImageView?
    
    @IBOutlet weak var createTimeL: UILabel?
    @IBOutlet weak var avatarTop: NSLayoutConstraint?
    var isHideTimeL: Bool = true {
        didSet {
            createTimeL?.isHidden = self.isHideTimeL
            self.avatarTop?.constant = self.isHideTimeL ? 10 : 47
        }
    }
    
    

    var imageBtn: UIButton?
    

    @IBOutlet weak var avatarBtn: UIButton?
    
    var dataMsg: CPMessage?
    


    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarBtn?.addTarget(self, action: #selector(onTapAvatar), for: .touchUpInside)
        

        imageBtn = UIButton()
        self.contentView.addSubview(imageBtn!)
        imageBtn?.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(pictureImage!)
        })
        imageBtn?.addTarget(self, action: #selector(onShowImage), for: .touchUpInside)
        
        self.stateIndicatorContainer?.isOpaque = false
        self.stateIndicatorContainer?.backgroundColor = UIColor(rgb: 0x303133, alpha: 0.3)
        self.stateIndicatorContainer?.tintColor = UIColor.clear
    }
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    @objc func onTapAvatar() {
        if let d = dataMsg {
            delegate?.onTapAvatar?(pubkey: d.senderPubKey)
        }
    }
    
    @objc func onShowImage() {
        if let image = pictureImage?.image {
            delegate?.onShowBigPhoto?(image, containerView: self)
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
        

        var width = 140.0
        var height = 140.0
        if let pw = dataMsg?.pixelWidth , let ph = dataMsg?.pixelHeight, pw > 0, ph > 0 {
            let fpw = CGFloat(pw)
            let fph = CGFloat(ph)
            
            if fpw > fph {
                width =  Double(CGFloat(fpw) / YYScreenScale())
                width = width > 140.0 ? 140.0 : width
                height = width * Double((fph / fpw))
                
            } else {
                height =  Double(CGFloat(fph) / YYScreenScale())
                height = height > 140.0 ? 140.0 : height
                width = height * Double((fpw / fph))
            }
        }
        
        self.imageWidth?.constant = CGFloat(width)
        self.imageHeight?.constant = CGFloat(height)
    }
    
    
    func hideLoading() {
        stateIndicatorContainer?.isHidden = true;
        stateIndicator?.isHidden = true;
        stateIndicator?.stopAnimating()
    }
    func showLoading() {
        stateIndicatorContainer?.isHidden = false;
        stateIndicator?.isHidden = false;
        stateIndicator?.startAnimating()
    }

    
    
    func updateSelf(msg: CPMessage) {

        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        

        var img = UIImage(named: "蓝色-聊天")
        img = img?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
        msgBgImgView?.image = img
        
        
        let expect = NSDate().timeIntervalSince1970 - 180
        if msg.toServerState == 0 || msg.toServerState == 3, msg.createTime > expect  {
            showLoading()
        } else {
            hideLoading()
        }
        
        let needRefresh:Bool = msg.pixelWidth == 0
        msg.normalCompleteHandle = { [weak self, weak msg] (result) in
            if msg?.fileHash != self?.dataMsg?.fileHash {
                return
            }
            self?.hideLoading()
            if result == true && (self?.pictureImage?.image == nil) {
                if let data =  msg?.msgDecodeContent() as? Data {
                    self?.pictureImage?.image = UIImage(data: data)
                }
            }
            
            if needRefresh && result {
                msg?.cellHeigth = 0
                if let vc = self?.viewController as? ChatRoomVC {
                    vc._refreshVisibleCells()
                }
            } else if result == false {
                self?.pictureImage?.image = UIImage(named: "pic_place")
            }
        }
        

        pictureImage?.image = UIImage(named: "pic_place")
        pictureImage?.nc_setImageHash(msg)
        

        smallRemarkL?.text = (CPAccountHelper.loginUser()?.accountName ?? "").getSmallRemark()
        
        sendStateImgV?.isHidden = !(msg.toServerState == 1)
        sendErrorBtn?.isHidden = !(msg.toServerState == 2)
    }
    
    func updateOthers(msg: CPMessage) {
        

        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        

        var img = UIImage(named: "灰色-聊天")
        img = img?.resizableImage(withCapInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), resizingMode: .stretch)
        msgBgImgView?.image = img
        

        self.showLoading()
        let needRefresh:Bool = msg.pixelWidth == 0
        msg.normalCompleteHandle = { [weak self,weak msg] (result) in
            if msg?.fileHash != self?.dataMsg?.fileHash {
                return
            }
            self?.hideLoading()
            if result == true && (self?.pictureImage?.image == nil) {
                if let data =  msg?.msgDecodeContent() as? Data {
                    self?.pictureImage?.image = UIImage(data: data)
                }
            }
            
            if needRefresh && (result == true) {
                msg?.cellHeigth = 0
                if let vc = self?.viewController as? ChatRoomVC {
                    vc._refreshVisibleCells()
                }
            }
            else if result == false {
                self?.pictureImage?.image = UIImage(named: "pic_place")
            }
        }
        

        pictureImage?.image = UIImage(named: "pic_place")
        pictureImage?.nc_setImageHash(msg)
        

        smallRemarkL?.text = RoomStatus.remark?.getSmallRemark()
        
        if msg.senderPubKey == support_account_pubkey {
            smallRemarkL?.text = nil
            smallAvatarImageV?.isHidden = false
            smallAvatarImageV?.image = UIImage(named: "subscript_icon")
        } else {
            smallAvatarImageV?.isHidden = true
        }
    }
    

    override func msgContentView() -> UIView? {
        return self.pictureImage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.dataMsg?.msgData = nil

    }
}
