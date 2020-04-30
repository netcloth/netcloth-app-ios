//
//  BTCWallet.swift
//  chat
//
//  Created by Grand on 2020/4/13.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation
import BitcoinKit

class BTCWallet: WalletInterface  {
    
    var chainID: Int32 = 1
    var identify: Wallet = .BTC
    
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
        let privatekey = PrivateKey(data: originPrikey, network: Network.mainnetBTC, isPublicKeyCompressed: true)
        let publickey = privatekey.publicKey()
        let address = publickey.toBitcoinAddress()
        return address.legacy
    }()
}
