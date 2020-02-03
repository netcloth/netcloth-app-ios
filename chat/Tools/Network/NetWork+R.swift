  
  
  
  
  
  
  

import Foundation

let BaseApi = "https:  

let StoreApi = "http:  
let SeedNode = "http:  

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
