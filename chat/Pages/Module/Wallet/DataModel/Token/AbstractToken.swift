







import Foundation

final class ResultObserver {
    deinit {
        print("dealloc (\(type(of: self))")
    }
    
    var transferCallBack: ((_ success: Bool, _ txHash: String?) -> Void)?
    
    
    var transferQuryTxHashCallBack: ((_ success: Bool, _ txHash: String?) -> Void)?
}

class AbstractToken: TokenInterface {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    var symbol: String
    
    var decimals: Int
    
    var name: String
    
    var address: String
    
    var logo_src: String
    
    var logo_ipfs_hash: String
    
    var wallet: WalletInterface
    
    var logo: UIImage? {
        fatalError("must override")
    }
    
    
    required init(wallet: WalletInterface, token: [String: Any]) {
        self.wallet = wallet
        
        let json = JSON(token)
        self.symbol = json["symbol"].stringValue
        self.decimals = json["decimals"].intValue
        self.name = json["name"].stringValue
        self.address = json["address"].stringValue
        
        self.logo_src = json["logo"]["src"].stringValue
        self.logo_ipfs_hash = json["logo"]["ipfs_hash"].stringValue
    }
    
    
    @discardableResult
    func fetchBalanceObserver() -> Observable<String> {
        fatalError("must overwrite")
    }
    
    func fetchBalance() -> Void {
        self.fetchBalanceObserver().subscribe(onNext: { (balance) in
        })
    }
    
    fileprivate lazy var _balance: BehaviorSubject<String> = {
        let b = BehaviorSubject<String>(value: "0")
        
        let chainid = self.wallet.chainID
        let symbol = self.symbol
        
        CPAssetTokenHelper.getBalanceWhereChain(chainid, symbol: symbol) { [weak self] (r, msg, blance) in
            if r {
                self?.changeCurrentBalance(balance: blance)
            }
        }
        return b
    }()
    
    var balance: BehaviorSubject<String> {
        return _balance
    }
    
    func storeCurrentBalance(balance: String) {
        changeCurrentBalance(balance: balance)
        CPAssetTokenHelper.insertOrUpdate(balance,
                                          whereChain: self.wallet.chainID,
                                          symbol: self.symbol,
                                          callback: nil)
    }
    
    fileprivate func changeCurrentBalance(balance: String) {
        self.balance.onNext(balance)
        self.wallet.totalChangeObserver.onNext(())
    }
    
    
    func transferTo(address: String,
                    amount: String,
                    memo: String = "",
                    callback: ResultObserver) -> Void {
        fatalError("must override")
    }
    
    func isValidAddress(addr: String) -> Bool {
        fatalError("must override")
    }
    
    
    func queryStatus(txHash: String, callback: ResultObserver) {
        
    }
}
