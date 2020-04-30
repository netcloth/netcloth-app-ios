







import Foundation

@objc class WalletDetailCell: UITableViewCell {
    @IBOutlet weak var logo : UIImageView?
    @IBOutlet weak var nameL : UILabel?
    @IBOutlet weak var amount : UILabel?
    @IBOutlet weak var totalPrice : UILabel?
    
    @IBOutlet weak var containerV : UIView?
    
    var data: Any?
    
    var disbag = DisposeBag()
    override func prepareForReuse() {
        super.prepareForReuse()
        disbag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerV?.fakesetLayerCornerRadiusAndShadow(10,
                                                           color: UIColor(hexString: Color.gray_bf)!,
                                                           offset: CGSize(width: 0, height: 2),
                                                           radius: 7,
                                                           opacity: 0.30)
    }
    
    
    override func reloadData(data: Any) {
        self.data = data
        if let wallet = data as? WalletInterface {
            self.reloadData(data: wallet)
        }
        else if let token = data as? TokenInterface {
            self.reloadData(data: token)
        }
    }
    
    fileprivate func reloadData(data: WalletInterface) {
        self.logo?.image = data.logo
        self.nameL?.text = data.name
        fillDataUI()
        
        NCUserCenter.shared?.walletManage.observable.subscribe(onNext: { [weak self] in
            self?.fillDataUI()
        }).disposed(by: self.disbag)
    }
    
    fileprivate func reloadData(data: TokenInterface) {
        self.logo?.image = data.wallet.logo
        self.nameL?.text = data.wallet.name
        
        
        data.balance.subscribe(onNext: { [weak self] (balance) in
            self?.fillTokenUI()
        }).disposed(by: self.disbag)
        
        NCUserCenter.shared?.walletManage.observable.subscribe(onNext: { [weak self] in
            self?.fillTokenUI()
        }).disposed(by: self.disbag)
    }
    
    
    fileprivate func fillDataUI() {
        
        let isShow = (NCUserCenter.shared?.walletManage.value.showPrice ?? true)
        if isShow {
            self.amount?.text = "0.00"
            self.totalPrice?.text = "$ 0.00"
        }
        else {
            self.amount?.text = "****"
            self.totalPrice?.text = "$ ****"
        }
    }
    
    fileprivate func fillTokenUI() {
        
        let isShow = (NCUserCenter.shared?.walletManage.value.showPrice ?? true)
        if isShow {
            var balance: String = (try? (self.data as? TokenInterface)?.balance.value()) ?? "0"
            var b = BigUInt(balance) ?? BigUInt(0)
            let bstr = WalletTokenHelper.parseAmount(amount: b,  formattingDecimals: 2)
            self.amount?.text = bstr
            
            self.totalPrice?.text = "$ 0.00"
        }
        else {
            self.amount?.text = "****"
            self.totalPrice?.text = "$ ****"
        }
    }
}
