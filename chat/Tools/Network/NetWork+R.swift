







import Foundation

let BaseApi = "https://app.netcloth.org"

let StoreApi = "http://47.104.189.5"
let SeedNode = "http://rpc.netcloth.org"

class APPURL {
    

    class Config {
        static let Info = BaseApi + "/config/info"
        
        static let UploadContact = StoreApi + "/v1/contacts"
        
        static let ContactsSummary = StoreApi + "/v1/contacts/{pubkey}/summary"
        static let ContactsContent = StoreApi + "/v1/contacts/{pubkey}/content"
    }
    

    class Chain {
        static let QueryCipalAddress = SeedNode + "/cipal/query/{addr}"
        
        static let CipalServerlist = SeedNode + "/ipal/list"
        static let QueryServerIPALNode = SeedNode + "/ipal/node/{addr}"
        
        static let QueryBlockHashStatus = SeedNode + "/txs/{tx_hash}"
    }
}
