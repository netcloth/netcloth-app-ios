







import Foundation
import BitcoinKit

class BCHWallet: WalletInterface  {
    
    var chainID: Int32 = 3
    var identify: Wallet = .BCH
    
    var name: String {
        if Bundle.is_zh_Hans() {
            return self.identify.rawValue + "Wallet".localized()
        }
        else {
            return self.identify.rawValue + " " + "Wallet".localized()
        }
    }
    
    var logo: UIImage {
        return UIImage(named: identify.rawValue)!
    }
    
    lazy var address: String = { () -> String in
        guard let originPrikey = OC_Chat_Plugin_Bridge.privateKeyOfLoginedUser() else {
                print("\(identify.rawValue)" + " decode error")
                return ""
        }
        let privatekey = PrivateKey(data: originPrikey, network: Network.mainnetBCH, isPublicKeyCompressed: true)
        let publickey = privatekey.publicKey()
        let address = publickey.toBitcoinAddress()
        return address.cashaddr
    }()
}
