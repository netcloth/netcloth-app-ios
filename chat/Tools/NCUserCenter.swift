//
//  NCUserCenter.swift
//  chat
//
//  Created by Grand on 2020/3/8.
//  Copyright © 2020 netcloth. All rights reserved.
//

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
    
    //MARK:- Property of Module
    var proxy: StoreObservable = StoreObservable(value: MiniAppProxyStore())
    
    /// Wallet
    lazy var walletDataStore:StoreObservable = StoreObservable(value: WalletDataStore())
    lazy var walletManage:StoreObservable = StoreObservable(value: WalletManageStore())
    
}
