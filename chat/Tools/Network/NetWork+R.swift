







import Foundation

let BaseApi = "https:

let StoreApi = "http:
let SeedNode = { () -> String in
    #if DEBUG
    if Config.isCusDeb {
        return "http:
    }
    #endif
    return "http:
}

final class APPURL {
    
    
    class Config {
        static let Info = BaseApi + "/config/info" 
        
        static let UploadContact = StoreApi + "/v1/contacts"
        
        static let ContactsSummary = StoreApi + "/v1/contacts/{pubkey}/summary"
        static let ContactsContent = StoreApi + "/v1/contacts/{pubkey}/content"
    }
    
    
    class Chain {
        static let QueryCipalAddress = SeedNode() + "/cipal/query/{addr}"
        
        static let CipalServerlist = SeedNode() + "/ipal/list"
        
        
        static let QueryServerIPALNode = SeedNode() + "/ipal/node/{addr}"
        
        static let QueryBlockHashStatus = SeedNode() + "/txs/{tx_hash}"
        
        
        
        
        static let balanceOfAddress = SeedNode() + "/bank/balances/{addr}"
        
        
        static let broadcastTransfer = SeedNode() + "/txs"
        
        static let accountsInfo = SeedNode() + "/auth/accounts/{addr}"

        
    }
    
    class Chain_Contract {
        static let all_ipal_list = SeedNode() + "/vm/estimate_gas"
    }
}
