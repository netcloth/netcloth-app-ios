  
  
  
  
  
  
  

import UIKit
import PromiseKit

class ChatService: NSObject {
    
    /*
     {
     "result": 0,
     "endpoints": ["47.104.248.183:4455"]
     }
     */
    
      
    static func requestLoadBalancing(endPoint: String) -> Promise<[String]> {
          
        let _promise = Promise<[String]> { (resolver) in
            let path = endPoint + "/v1/service/gateway?pub_key=" + (CPAccountHelper.loginUser()?.publicKey ?? "")
            NW.requestUrl(path: path, method: .get, para: nil) { (r, res) in
                if r == true, (res as? NSDictionary) != nil {
                    let json = JSON(res)
                    if json["result"].intValue == 0 {
                        if let endpoints = json["endpoints"].arrayObject as? [String] {
                            resolver.fulfill(endpoints)
                        } else {
                            let error = NSError(domain: "requestLoadBalancing-fail-1", code: 31, userInfo: nil)
                            resolver.reject(error)
                        }
                    } else {
                        let error = NSError(domain: "requestLoadBalancing-fail-3", code: 33, userInfo: nil)
                        resolver.reject(error)
                    }
                } else {
                    let error = NSError(domain: "requestLoadBalancing-fail-2", code: 32, userInfo: nil)
                    resolver.reject(error)
                }
            }
        }
        return _promise
    }
    
    static func connectChatServer(allEndPoints: [String]) -> Promise<Bool> {
        let _promise = Promise<Bool> { (resolver) in
            CPAccountHelper.connectAllChatEnterPoint(allEndPoints)
            self.observerResultNotify(resolver: resolver)
        }
        return _promise
    }
    
    static var obv1: NSObjectProtocol?
    static func observerResultNotify(resolver: (Resolver<Bool>)) {
        if obv1 != nil {
            NotificationCenter.default.removeObserver(obv1)
        }
        obv1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.serviceConnectStatusChange, object: nil, queue: OperationQueue.main) { (notice) in
            if CPAccountHelper.isConnected() {
                resolver.fulfill(true)
            } else {
                if CPAccountHelper.isNetworkOk() {
                    
                } else {
                    resolver.fulfill(false)
                }
            }
        }
    }
}
