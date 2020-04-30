//
//  AssetsToken.swift
//  chat
//
//  Created by Grand on 2020/4/24.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

protocol TokenInterface {
    var symbol: String {get}
    var decimals: Int {get}
    var name: String {get}
    
    /// contract addr ?
    var address: String {get}
    
    var logo_src: String {get}
    var logo_ipfs_hash: String {get}
    
    /// optional
    var logo: UIImage?   {get}
    var wallet: WalletInterface { get }
    
    /// func
    init(wallet: WalletInterface, token: [String: Any])
    
    /// Asset
    var balance: BehaviorSubject<String> {get}
    
    @discardableResult
    func fetchBalanceObserver() -> Observable<String>
    func fetchBalance() -> Void
    
    func storeCurrentBalance(balance: String)
    
    /// transfer
    /// - Parameters:
    ///   - address: <#address description#>
    ///   - amount: 最小单元
    ///   - memo: <#memo description#>
    ///   - callback: <#callback description#>
    func transferTo(address: String,
                    amount: String,
                    memo: String, //备注
                    callback: ResultObserver) -> Void
    
    //MARK:-  Helper
    func isValidAddress(addr: String) -> Bool
    
    func queryStatus(txHash: String, callback: ResultObserver)
}
