







import Foundation
import web3swift

class ContractService: NSObject {
    
    static func findAllIPALList() -> Promise<EnterPoint> {
        let _promise = Promise<EnterPoint> { (resolver) in
            var para =  [String:Any]()
            para["from"] = "nch17czruqxgl2ndye4p0z86hn7a25mwl5lh89j9ur"
            para["to"] = "nch17czruqxgl2ndye4p0z86hn7a25mwl5lh89j9ur"
            para["payload"] = "a23e3e08000000000000000000000000c7bb0a77e5dc6de40214c1bb074cca2503bf10d2"
            var amount = [String:Any]()
            amount["denom"] = "pnch"
            amount["amount"] = "0"
            para["amount"] = amount

            
            NW.requestUrl(path: APPURL.Chain_Contract.all_ipal_list, method: .post, para: para) { (r, res) in
                guard let data = res as? NSDictionary, r else {
                    let error = NSError(domain: "requestAllChatServer", code: 12, userInfo: nil)
                    resolver.reject(error)
                    return
                }
                
                guard let result = data["result"] as? NSDictionary else {
                    let error = NSError(domain: "requestAllChatServer", code: 12, userInfo: nil)
                    resolver.reject(error)
                    return
                }
                
                let Res = result["Res"]
                
                
                let AllNode: [IPALNode]? = NSArray.modelArray(with: IPALNode.self, json: result) as? [IPALNode]
                
                let chatEnters = AllNode?.filter({ (item:IPALNode) -> Bool in
                    if let endpoints = item.endpoints {
                        for address in endpoints {
                            if address.type == "1" {
                                return true
                            }
                        }
                    }
                    return false
                })
                if chatEnters?.isEmpty == true || AllNode == nil {
                    let error = NSError(domain: "requestAllChatServer-empty", code: 13, userInfo: nil)
                    resolver.reject(error)
                    return
                }
                resolver.fulfill(AllNode!)
            }
        }
        return _promise;
    }
    
    
    func decodeRes(res: String) {
        var res = "00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000f42400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000116e6574636c6f74682d6f6666696369616c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003277b226f70657261746f725f61646472657373223a226e636831306a7a70743332677772616476396d636e72366675756a30746e783772713070736d6d746a75222c226d6f6e696b6572223a226e6574636c6f74682d6f6666696369616c222c2277656273697465223a226e6574636c6f74682e6f7267222c2264657461696c73223a226e6574636c6f74682d6f6666696369616c222c22656e64706f696e7473223a5b7b2274797065223a2231222c22656e64706f696e74223a22687474703a2f2f34372e3130342e3138392e35227d2c7b2274797065223a2233222c22656e64706f696e74223a22687474703a2f2f34372e39302e352e313338227d2c7b2274797065223a2234222c22656e64706f696e74223a227b5c226d696e69417070446f6d61696e735c223a5b7b5c226d6f6e696b65725c223a5c224e6574436c6f746820426c6f675c222c5c22646f6d61696e5c223a5c2268747470733a2f2f626c6f672e6e6574636c6f74682e6f72675c227d2c7b5c226d6f6e696b65725c223a5c22e993bee997bbe7a4be5c222c5c22646f6d61696e5c223a5c2268747470733a2f2f7777772e636861696e6e6577732e636f6d2f5c227d2c7b5c226d6f6e696b65725c223a5c22e99d9ee5b08fe58fb75c222c5c22646f6d61696e5c223a5c2268747470733a2f2f6665697869616f68616f2e636f6d5c227d2c7b5c226d6f6e696b65725c223a5c22e98791e8b4a2e5bfabe8aeaf5c222c5c22646f6d61696e5c223a5c2268747470733a2f2f6d2e6a696e73652e636f6d2f6c697665735c227d2c7b5c226d6f6e696b65725c223a5c224e6574436c6f746820426c6f675c222c5c22646f6d61696e5c223a5c2268747470733a2f2f6d656469756d2e636f6d2f404e6574436c6f74682f5c227d2c7b5c226d6f6e696b65725c223a5c22436f696e6465736b5c222c5c22646f6d61696e5c223a5c2268747470733a2f2f7777772e636f696e6465736b2e636f6d5c227d2c7b5c226d6f6e696b65725c223a5c22436f696e6d61726b65746361705c222c5c22646f6d61696e5c223a5c2268747470733a2f2f7777772e636f696e6d61726b65746361702e636f6d205c227d5d7d227d5d7d00000000000000000000000000000000000000000000000000"
        
        let data = Data()
        let contract = getContract()
        if let methods = contract?.allMethods {
            for item in  methods {
                if let dic = contract?.decodeReturnData(item, data: data) {
                    print(item, dic)
                }
            }
        }
        
    }
    
    func getContract() -> EthereumContract? {
        let abistr = """
        [
         {
          "inputs": [
           {
            "internalType": "address",
            "name": "newAdminAccountAddress",
            "type": "address"
           }
          ],
          "name": "auth",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "string",
            "name": "cipalDeclaration",
            "type": "string"
           },
           {
            "internalType": "address",
            "name": "userAddr",
            "type": "address"
           },
           {
            "internalType": "bytes32",
            "name": "R",
            "type": "bytes32"
           },
           {
            "internalType": "bytes32",
            "name": "S",
            "type": "bytes32"
           },
           {
            "internalType": "uint8",
            "name": "V",
            "type": "uint8"
           }
          ],
          "name": "cipalClaim",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "address",
            "name": "addr",
            "type": "address"
           }
          ],
          "name": "ipalApprove",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "string",
            "name": "moniker",
            "type": "string"
           },
           {
            "internalType": "string",
            "name": "ipalDeclaration",
            "type": "string"
           }
          ],
          "name": "ipalClaim",
          "outputs": [],
          "stateMutability": "payable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "string",
            "name": "moniker",
            "type": "string"
           }
          ],
          "name": "ipalClaim1",
          "outputs": [
           {
            "internalType": "bool",
            "name": "",
            "type": "bool"
           }
          ],
          "stateMutability": "payable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "address",
            "name": "addr",
            "type": "address"
           },
           {
            "internalType": "enum Ipal.UnApproveReason",
            "name": "reason",
            "type": "uint8"
           }
          ],
          "name": "ipalUnApprove",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
         },
         {
          "inputs": [],
          "name": "ipalUnClaim",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "string",
            "name": "moniker",
            "type": "string"
           },
           {
            "internalType": "string",
            "name": "ipalDeclaration",
            "type": "string"
           }
          ],
          "name": "ipalUpdate",
          "outputs": [],
          "stateMutability": "payable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "uint256",
            "name": "newMinBond",
            "type": "uint256"
           }
          ],
          "name": "updateMinBond",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "address",
            "name": "",
            "type": "address"
           }
          ],
          "name": "cipals",
          "outputs": [
           {
            "internalType": "string",
            "name": "",
            "type": "string"
           }
          ],
          "stateMutability": "view",
          "type": "function"
         },
         {
          "inputs": [],
          "name": "getIpalKeys",
          "outputs": [
           {
            "internalType": "address[]",
            "name": "v",
            "type": "address[]"
           }
          ],
          "stateMutability": "view",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
           }
          ],
          "name": "ipalKeys",
          "outputs": [
           {
            "internalType": "address",
            "name": "",
            "type": "address"
           }
          ],
          "stateMutability": "view",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "address",
            "name": "",
            "type": "address"
           }
          ],
          "name": "ipals",
          "outputs": [
           {
            "internalType": "string",
            "name": "moniker",
            "type": "string"
           },
           {
            "internalType": "string",
            "name": "ipalDeclaration",
            "type": "string"
           },
           {
            "internalType": "uint256",
            "name": "bond",
            "type": "uint256"
           },
           {
            "internalType": "bool",
            "name": "isApproved",
            "type": "bool"
           },
           {
            "internalType": "enum Ipal.UnApproveReason",
            "name": "unApproveReason",
            "type": "uint8"
           }
          ],
          "stateMutability": "view",
          "type": "function"
         },
         {
          "inputs": [
           {
            "internalType": "string",
            "name": "",
            "type": "string"
           }
          ],
          "name": "monikerExistChecker",
          "outputs": [
           {
            "internalType": "bool",
            "name": "",
            "type": "bool"
           }
          ],
          "stateMutability": "view",
          "type": "function"
         }
        ]
        """
        let contract = EthereumContract(abistr)
        
        return contract
    }
}
