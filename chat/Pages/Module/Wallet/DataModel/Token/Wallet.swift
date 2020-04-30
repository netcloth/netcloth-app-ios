







import UIKit
import BigInt

protocol WalletInterface {
    var identify: Wallet { get }
    var name: String { get }
    var logo: UIImage { get }
    
    
    var address: String { get }
    
    
    var chainID: Int32 {get}
    var assetTokens: [TokenInterface] {get}
    
    
    var totalBalance: BigUInt {get}
    var totalChangeObserver: PublishSubject<Void> {get}
    
    func fetchTotalBalance() ->Void
}

fileprivate var key_ext = "key_ext"
extension WalletInterface {
    
    var assetTokens: [TokenInterface] {
        return []
    }
    var totalBalance: BigUInt {
        var total: BigUInt = BigUInt("0")
        for item in self.assetTokens {
            if let blance = try? item.balance.value(),
                let big =  BigUInt(blance) {
                total += big
            }
        }
        return total
    }
    
    var totalChangeObserver: PublishSubject<Void>  {
        get {
            if let s = objc_getAssociatedObject(self, &key_ext) as? PublishSubject<Void> {
                return s
            }
            else {
                let s = PublishSubject<Void>()
                objc_setAssociatedObject(self, &key_ext, s, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return s
            }
        }
    }
    
    func fetchTotalBalance() ->Void {
        for item in self.assetTokens {
            item.fetchBalance()
        }
    }
}


enum Wallet: String {
    case CateALL
    case NCH
    case BTC
    case ETH
    case BCH
    case BSV
    case LTC
    case XMR
    case TRX
}

extension Wallet {
    func wallet() -> WalletInterface {
        switch self {
        case .CateALL:
            return FakeAllWallet()
        case .NCH:
            return NCHWallet()
        case .BTC:
            return BTCWallet()
        case .ETH:
            return ETHWallet()
        case .BCH:
            return BCHWallet()
            
        default:
            return NCHWallet()
        }
    }
}

class FakeAllWallet: WalletInterface  {
    
    var chainID: Int32 = -1
    
    
    var identify: Wallet {
        return .CateALL
    }
    
    var name: String {
        return "ALL" + "Wallet".localized()
    }
    
    var logo: UIImage {
        return UIImage(named: "Wallet_All")!
    }
    var address: String = ""
}
