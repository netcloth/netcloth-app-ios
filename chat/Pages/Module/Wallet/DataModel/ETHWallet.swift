







import Foundation
import web3swift

class ETHWallet: WalletInterface  {
    
    var chainID: Int32 = 2
    var identify: Wallet = .ETH
    
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
        
        guard let privatekey = OC_Chat_Plugin_Bridge.privateKeyOfLoginedUser(),
            let publicKey = Web3.Utils.privateToPublic(privatekey) else {
                print("\(identify.rawValue)" + " decode error")
                return ""
        }
        
        let hexAddress = Web3.Utils.publicToAddressString(publicKey)
        return hexAddress ?? ""
    }()
}
