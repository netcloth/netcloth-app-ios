







import UIKit

class TradeListCell: UITableViewCell {
    
    @IBOutlet weak var iconImgV: UIImageView?
    
    @IBOutlet weak var toAddrL: UILabel?
    @IBOutlet weak var dateL: UILabel?
    
    
    @IBOutlet weak var totalL: UILabel?
    @IBOutlet weak var statusL: UILabel?
    
    
    var iconImageName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var disbag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disbag = DisposeBag()
    }
    
    var data: CPTradeRsp?
    override func reloadData(data: Any) {
        guard let d = data as? CPTradeRsp else {
            return
        }
        self.data = d
        
        self.reloadData(d: d)
        
        d.rx.observe(CPTradeRsp.self, "status")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (e) in
                if let dm = self?.data {
                    self?.reloadData(d: dm)
                }
            }).disposed(by: disbag)
       
    }
    
    fileprivate func reloadData(d: CPTradeRsp) {
        if let name = iconImageName {
            self.iconImgV?.image = UIImage(named: name)
        }
        else {
            if d.status == .fail {
                self.iconImgV?.image = UIImage(named: "trade_fail")
            }
            else if d.type == .transfer {
                self.iconImgV?.image = UIImage(named: "trade_out")
            }
        }
        
        
        self.toAddrL?.text = d.toAddr
        
        let date = NSDate(timeIntervalSince1970: d.createTime)
        var datestr: String?
        datestr = date.string(withFormat: "yyyy-MM-dd HH:mm")





        
        self.dateL?.text = datestr
        
        
        var decimal = 12
        if let token = NCUserCenter.shared?.walletDataStore.value.assetTokenOf(chainId: Int(d.chainId), symbol: d.symbol) {
            decimal = token.decimals
        }
        
        let total = d.amount.toDecimalBalance(bydecimals: decimal)
        
        if d.type == .transfer {
            self.totalL?.text = "- \(total)"
        }
        
        
        let status = statusDescOfItem(d: d)
        self.statusL?.text = status.desc
        self.statusL?.textColor = UIColor(hexString: status.color)
    }
    
    fileprivate func statusDescOfItem(d: CPTradeRsp) -> (desc: String, color: String) {
        let status = d.status
        if status == .wait {
            return ( "waiting for packaging".localized(),  Color.blue)
        }
        else if status == .query {
            return ( "confirming".localized(),  Color.blue)
        }
        else if status == .success {
            return ( "success".localized(),  "#169A41")
        }
        else if status == .fail {
            return ( "fail".localized(),  Color.red)
        }
        return ("", "")
    }
}
