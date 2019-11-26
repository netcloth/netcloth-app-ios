







import UIKit

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView?
    @IBOutlet weak var hubimg: UIImageView?
    @IBOutlet weak var nameL: UILabel?
    @IBOutlet weak var timeL: UILabel?
    @IBOutlet weak var stateL: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container?.fakesetLayerCornerRadiusAndShadow(4,
                                                      color: UIColor(rgb: 0xBFC2CC),
                                                      offset: CGSize(width: 0, height: 2),
                                                      radius: 7,
                                                      opacity: 0.3)
    }
    
    override func reloadData(data: Any) {
        guard let claim = data as? CPChainClaim else {
            return
        }
        nameL?.text = claim.moniker
        timeL?.text = NSDate(timeIntervalSince1970: claim.createTime).string(withFormat: "yyyy-MM-dd HH:mm:ss")
        
        let aync = claim.calStates()
        hubimg?.image = UIImage(named: aync.dotName)
        stateL?.text = aync.desc
        stateL?.textColor = aync.color
            
    }
}

extension CPChainClaim {
    func calStates() -> (dotName:String, desc: String, color: UIColor)
    {
        if self.chain_status == 1 {
            return ("dot_green","history_Success".localized(),UIColor(hexString: "#5ABB27")!)
        } else if self.chain_status == 2 {
            return ("dot_yellow","history_Fail".localized(),UIColor(hexString: "#F77221")!)
        } else {
            return ("dot_blue","history_Pending".localized(),UIColor(hexString: "#3D7EFF")!)
        }
    }
}
