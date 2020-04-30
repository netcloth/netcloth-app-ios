







import Foundation

protocol TokenInterface {
    var symbol: String {get}
    var decimals: Int {get}
    var name: String {get}
    
    
    var address: String {get}
    
    var logo_src: String {get}
    var logo_ipfs_hash: String {get}
    
    
    var logo: UIImage?   {get}
    var wallet: WalletInterface { get }
    
    
    init(wallet: WalletInterface, token: [String: Any])
    
    
    var balance: BehaviorSubject<String> {get}
    
    @discardableResult
    func fetchBalanceObserver() -> Observable<String>
    func fetchBalance() -> Void
    
    func storeCurrentBalance(balance: String)
    
    
    
    
    
    
    
    func transferTo(address: String,
                    amount: String,
                    memo: String, 
                    callback: ResultObserver) -> Void
    
    
    func isValidAddress(addr: String) -> Bool
    
    func queryStatus(txHash: String, callback: ResultObserver)
}
