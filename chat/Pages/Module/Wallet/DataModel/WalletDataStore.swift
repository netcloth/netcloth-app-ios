//
//  WalletDataStore.swift
//  chat
//
//  Created by Grand on 2020/4/13.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

/// change property only use NCUserCenter
class WalletDataStore: NSObject {
    
    fileprivate var _list: [WalletInterface] = [Wallet.CateALL.wallet(),
                                                Wallet.NCH.wallet(),
                                                Wallet.BTC.wallet(),
                                                Wallet.ETH.wallet(),
                                                Wallet.BCH.wallet(),]
    
    var list: [WalletInterface] {
        get {
            return _list
        }
    }
    
    
    //MARK:- Find
    func walletOfChainId(_ id: Int) -> WalletInterface? {
        for item in list {
            if item.chainID == id {
                return item
            }
        }
        return nil
    }
    
    func assetTokenOf(chainId: Int, symbol: String) -> TokenInterface? {
        let wallet = self.walletOfChainId(chainId)
        for item in (wallet?.assetTokens ?? []) {
            if item.symbol == symbol {
                return item
                break
            }
        }
        return nil
    }
    
    
    /// default select All
    var curSection: Int = 0
    
    func listOfCurSection() -> [WalletInterface] {
        if curSection == 0 {
            return  Array(list.suffix(from: 1))
        }
        let item = list[curSection]
        return  [ item ]
    }
}

class WalletManageStore: NSObject {
    
    fileprivate lazy var _showPrice:Bool =  { () -> Bool in
        if let t = UserSettings.object(forKey: "wallet_show_price") as? Bool {
            return t
        }
        return true
    }()
    
    var showPrice: Bool {
        set {
            _showPrice = newValue
            UserSettings.setObject(newValue, forKey: "wallet_show_price")
        }
        get {
            return _showPrice
        }
    }
    
    /// 当前是否在创建钱包中
    var inCreatingWallet: Bool = false
}
