







import UIKit

fileprivate var _instance: NCUserCenter?
class NCUserCenter: NSObject {
    static var shared: NCUserCenter? {
        return _instance
    }
    static func onLogoin() {
        _instance = NCUserCenter()
    }
    static func onLogout() {
        _instance = nil
    }
    
    
    var proxy: StoreObservable = StoreObservable(value: MiniAppProxyStore())
    
    
    lazy var walletDataStore:StoreObservable = StoreObservable(value: WalletDataStore())
    lazy var walletManage:StoreObservable = StoreObservable(value: WalletManageStore())
    
}
