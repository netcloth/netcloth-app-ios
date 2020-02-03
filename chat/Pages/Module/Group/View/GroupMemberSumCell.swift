  
  
  
  
  
  
  

import UIKit

class GroupMemberSumCell: UICollectionViewCell {
    
    @IBOutlet weak var smallRemark: UILabel?
    @IBOutlet weak var remark: UILabel?
    @IBOutlet weak var placeIV : UIImageView?
    
    override func reloadData(data: Any) {
        if let d = data as? CPGroupMember {
            smallRemark?.text = d.nickName.getSmallRemark()
            remark?.text = d.nickName
            
            let type = d.fakePlaceType
            smallRemark?.isHidden = !(type == 0)
            remark?.isHidden = !(type == 0)
            placeIV?.isHidden = (type == 0)
            if type == 1 {
                placeIV?.image = UIImage(named: "group_btn_add")
            }
            else if type == 2 {
                placeIV?.image = UIImage(named: "group_btn_del")
            }
    
        }
    }
    
}
