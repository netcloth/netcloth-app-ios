//
//  NetWork+R.swift
//  chat
//
//  Created by Grand on 2019/8/13.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

let BaseApi = "https://app.netcloth.org"

let StoreApi = "http://storage.netcloth.org"
let SeedNode = { () -> String in
    #if DEBUG
    if Config.isCusDeb {
        return "http://47.104.248.183/nch"
    }
    #endif
    return "http://rpc.netcloth.org"
}

final class APPURL {
    
    /// for chat server
    class Config {
        static let Info = BaseApi + "/config/info" //check app upgrade info
        
        static let UploadContact = StoreApi + "/v1/contacts"
        
        static let ContactsSummary = StoreApi + "/v1/contacts/{pubkey}/summary"
        static let ContactsContent = StoreApi + "/v1/contacts/{pubkey}/content"
    }
    
    /// for chain node
    class Chain {
        static let QueryCipalAddress = SeedNode() + "/cipal/query/{addr}"
        
        static let CipalServerlist = SeedNode() + "/ipal/list"
        
        /// replace with server address
        static let QueryServerIPALNode = SeedNode() + "/ipal/node/{addr}"
        
        static let QueryBlockHashStatus = SeedNode() + "/txs/{tx_hash}"
        
        
        /// asset
        /// 账户余额
        static let balanceOfAddress = SeedNode() + "/bank/balances/{addr}"
        
        /// 广播交易
        static let broadcastTransfer = SeedNode() + "/txs"
        /// 查询账户信息
        static let accountsInfo = SeedNode() + "/auth/accounts/{addr}"

        
    }
    
    class Chain_Contract {
        static let all_ipal_list = SeedNode() + "/vm/estimate_gas"
    }
}
