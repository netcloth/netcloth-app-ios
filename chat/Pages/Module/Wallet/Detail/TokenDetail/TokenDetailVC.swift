







import UIKit


class TokenDetailVC: BaseViewController {
    
    @IBOutlet weak var logoImgV: UIImageView?
    @IBOutlet weak var nameL: UILabel?
    @IBOutlet weak var balanceL: UILabel?
    @IBOutlet weak var priceL: UILabel?
    
    @IBOutlet weak var transferBtn: UIButton?
    @IBOutlet weak var recieveBtn: UIButton?
    
    let disbag = DisposeBag()
    
    var token: TokenInterface?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TokenTradeStatisticsVC {
            self.addChild(vc)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.token?.fetchBalance()
    }
    
    func configUI() {
        self.title = self.token?.wallet.name
        logoImgV?.image = self.token?.logo
        nameL?.text = self.token?.name
        
        self.token?.balance.subscribe(onNext: { [weak self] (balance) in
            let dcm = self?.token?.decimals ?? 12
            let todec = balance.toDecimalBalance(bydecimals: dcm)
            self?.balanceL?.text = todec
        }).disposed(by: disbag)
        
        self.priceL?.text = "0.00"
    }
    
    func configEvent() {
       
    }
    
    
    @IBAction func toTransferPage() {
        if let vc = R.loadSB(name: "TokenTransferVC", iden: "TokenTransferVC") as? TokenTransferVC {
            vc.token = self.token
            Router.pushViewController(vc: vc)
        }
    }
    
    @IBAction func toRecieveCoin() {
        if let vc = R.loadSB(name: "WalletQRCodeVC", iden: "WalletQRCodeVC") as? WalletQRCodeVC {
            vc.wallet = self.token?.wallet
            Router.pushViewController(vc: vc)
        }
    }
    
    

}
