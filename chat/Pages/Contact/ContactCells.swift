//
//  ContactCells.swift
//  chat
//
//  Created by Grand on 2019/11/25.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

@objc class ContactCell: UITableViewCell {
    
    @IBOutlet weak var small: UILabel!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    @IBOutlet weak var groupAvatar: GroupAvatarView?
    @IBOutlet weak var LgroupMasterIden: PaddingLabel?
    
    var smallBgColor: UIColor?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustOffset()
        smallBgColor = small.backgroundColor
        self.smallAvatarImageV?.layer.borderWidth = 1.0
        self.smallAvatarImageV?.layer.borderColor = UIColor(hexString: Color.gray_d8)!.cgColor
        self.smallAvatarImageV?.contentMode = .scaleAspectFill
        self.LgroupMasterIden?.edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        self.LgroupMasterIden?.text = "Founder".localized()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        small.backgroundColor = smallBgColor
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
//        small.backgroundColor = smallBgColor
    }
    
    fileprivate var wData: Any?
    override func reloadData(data: Any) {
        wData = data
        if let d = data as? CPContact {
            _reloadData(d)
        }
        else if let d = data as? CPGroupMember {
            _reloadData(d)
        }
    }
    
    fileprivate func _reloadData(_ d: CPContact) {
        remark.text = d.remark
        small.text = d.remark.getSmallRemark()
                
        let color = d.publicKey.randomColor()
        small?.backgroundColor = UIColor(hexString: color)
        
        if d.sessionType == SessionType.group {
            groupAvatar?.isHidden = false
            small.isHidden = true
            smallAvatarImageV?.isHidden = true
            
            if d.groupRelateMember.isEmpty {
                groupAvatar?.isHidden = true
                small.isHidden = false
            }
            else {
                groupAvatar?.reloadData(members: d.groupRelateMember)
            }
        }
        else {
            groupAvatar?.isHidden = true
            small.isHidden = false
            if let a = d.publicKey.isAssistHelper(),
                a.avatar.isEmpty == false {
                small.text = nil
                smallAvatarImageV?.isHidden = false
                smallAvatarImageV?.nc_typeImage(url: a.avatar)
                small?.isHidden = true
            }
            else {
                smallAvatarImageV?.isHidden = true
                small?.isHidden = false
            }
        }
    }
    
    fileprivate func _reloadData(_ d: CPGroupMember) {
        let name = d.nickName
        remark.text = name
        small.text = name.getSmallRemark()
        
        let color = d.hexPubkey.randomColor()
        small?.backgroundColor = UIColor(hexString: color)
    }
    
    fileprivate func getPublicKey() -> String {
        if let d = wData as? CPContact {
            return d.publicKey
        }
        else if let d = wData as? CPGroupMember {
            return d.hexPubkey
        }
        return ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //identify
        self.LgroupMasterIden?.isHidden = true
        if let masterPubkey = self.viewController?.roomService?.groupMasterPubkey,
            getPublicKey() == masterPubkey {
            self.LgroupMasterIden?.isHidden = false
        }
    }
}

//newFriends
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
        leftText?.textColor = UIColor(hexString: Color.black)
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
