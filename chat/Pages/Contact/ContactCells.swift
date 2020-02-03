  
  
  
  
  
  
  

import Foundation

@objc class ContactCell: UITableViewCell {
    
    @IBOutlet weak var small: UILabel!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    @IBOutlet weak var groupAvatar: GroupAvatarView?
    
    var smallBgColor: UIColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustOffset()
        smallBgColor = small.backgroundColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        small.backgroundColor = smallBgColor
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        small.backgroundColor = smallBgColor
    }
    
    
    override func reloadData(data: Any) {
        if let d = data as? CPContact {
            remark.text = d.remark
            small.text = d.remark.getSmallRemark()
            
            if d.sessionType == SessionType.group {
                groupAvatar?.isHidden = false
                small.isHidden = true
                smallAvatarImageV?.isHidden = true
                
                if d.groupRelateMemberNick.isEmpty {
                    groupAvatar?.isHidden = true
                    small.isHidden = false
                } else {
                    groupAvatar?.reloadData(nickNames: d.groupRelateMemberNick)
                }
                
            } else {
                groupAvatar?.isHidden = true
                small.isHidden = false
                if d.publicKey == support_account_pubkey {
                    small.text = nil
                    smallAvatarImageV?.isHidden = false
                    smallAvatarImageV?.image = UIImage(named: "subscript_icon")
                } else {
                    smallAvatarImageV?.isHidden = true
                }
            }
        }
        else if let d = data as? CPGroupMember {
            let name = d.nickName
            remark.text = name
            small.text = name.getSmallRemark()
        }
    }
}

  
class ContactModuleEnterCell: UITableViewCell {
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    @IBOutlet weak var leftTitleL: UILabel?
    @IBOutlet weak var rightDescL: UILabel?
    @IBOutlet weak var sepV: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustOffset()
    }
}


class ContactSectionHeader: UITableViewHeaderFooterView {
    var leftText: UILabel?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        leftText = UILabel()
        leftText?.textColor = UIColor(hexString: "#303133")
        leftText?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(leftText!)
        
        leftText?.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(15)
            make.centerY.equalTo(self)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
