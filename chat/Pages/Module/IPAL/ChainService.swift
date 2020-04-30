//
//  ChainService.swift
//  chat
//
//  Created by Grand on 2019/11/12.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import Alamofire
import SBJson5
import YYKit

class ChainService: NSObject {
    
    //MARK: - Step1
    static func requestLastRegisterInfo() -> Promise<String?> {
        
        let _promise = Promise<String?> { (resolver) in
            if let address = OC_Chat_Plugin_Bridge.addressOfLoginUser() {
                let path = APPURL.Chain.QueryCipalAddress.replacingOccurrences(of: "{addr}", with: address)
                NW.requestUrl(path: path, method: .get, para: nil) { (r, res) in
                    guard let data = res as? NSDictionary, r else {
                        let error = NSError(domain: "requestLastRegisterInfo", code: 13, userInfo: nil)
                        resolver.reject(error)
                        return
                    }
                    let json = JSON(data)
                    let service_infos = json["result"]["service_infos"]
                    
                    var address: String?
                    for (index,subJson):(String, JSON) in service_infos {
                        if subJson["type"].intValue == 1 {
                            address = subJson["address"].string
                            break;
                        }
                    }
                    resolver.fulfill(address)
                }
            }
        }
        return _promise;
    }
    
    //request all user
    static func requestAllChatServer() -> Promise<EnterPoint> {
        let _promise = Promise<EnterPoint> { (resolver) in
            NW.requestUrl(path: APPURL.Chain.CipalServerlist, method: .get, para: nil) { (r, res) in
                guard let data = res as? NSDictionary, r else {
                    let error = NSError(domain: "requestAllChatServer", code: 12, userInfo: nil)
                    resolver.reject(error)
                    return
                }
                
                let result = data["result"]
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
    
    
    
    //MARK: - Step2 bind
    /// txhash
    static func requestBindCIpal(node: IPALNode) -> Promise<String> {
        let prikey = OC_Chat_Plugin_Bridge.privateKeyOfLoginedUser()
        return ipalBind(node: node, byPrivateKey: prikey ?? Data())
    }
    
    static func queryServerNodeByAddress(server_address: String) -> Promise<IPALNode> {
        let _promise = Promise<IPALNode> { (resolver) in
            //hex
            let path = APPURL.Chain.QueryServerIPALNode.replacingOccurrences(of: "{addr}", with: server_address)
            NW.requestUrl(path: path, method: .get, para: nil) { (r, res) in
                
                if r == true,  let data = res as? NSDictionary, let result = data["result"] as? NSDictionary  {
                    let node: IPALNode? =  IPALNode.model(with: result as! [AnyHashable : Any])
                    if let n = node, n.cIpalEnd() != nil {
                        resolver.fulfill(n)
                    } else {
                        let error = NSError(domain: "queryBindNodeStatus-fail-1", code: 25, userInfo: nil)
                        resolver.reject(error)
                    }
                } else {
                    let error = NSError(domain: "queryBindNodeStatus-fail", code: 25, userInfo: nil)
                    resolver.reject(error)
                }
            }
        }
        return _promise;
    }
    
    //MARK:- Bind Group
    ///bindType: 1 chat ， 2 groupchat
    static func ipalBind(node:IPALNode,bindType: Int = 1, byPrivateKey: Data) -> Promise<String> {
        let _promise = Promise<String> { (resolver) in
            guard let server = node.cIpalEnd(), let enter = server.endpoint else {
                let error = NSError(domain: "requestBindCIpal-empty", code: 23, userInfo: nil)
                resolver.reject(error)
                return
            }
            
            let useraddress = OC_Chat_Plugin_Bridge.address(ofUserPrivateKey: byPrivateKey)
            
            let timezone = TimeZone(identifier: "UTC")
            let locale = Locale.current //Locale(identifier: "en_US_POSIX")
            let time = NSDate(timeIntervalSinceNow: 180)
                .string(withFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", timeZone: timezone, locale: locale)
            
            var dic = NSMutableDictionary()
            var params = NSMutableDictionary()
            params["expiration"] = time
            
            var service_info = NSMutableDictionary()
            service_info["address"] = node.operator_address
            service_info["type"] = bindType
            
            params["service_info"] = service_info
            params["user_address"] = useraddress
            
            dic["params"] = params
            
            //get sign
            let writer:SBJson5Writer = SBJson5Writer.writer(withMaxDepth: 20, humanReadable: false, sortKeys: true) as! SBJson5Writer
            let jsonData = writer.data(with: params)
            let sha256 = jsonData?.sha256()
            let cal_signature = OC_Chat_Plugin_Bridge.signedContentHash(sha256, ofUserPrivateKey: byPrivateKey)?.toHexString()
            
            var signature = NSMutableDictionary()
            signature["pub_key"] = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofUserPrivateKey: byPrivateKey)
            signature["signature"] = cal_signature
            
            dic["signature"] = signature
            
            let urlString = enter + "/v1/ipal/claim"
            let url = URL(string: urlString)!
            let postBody = writer.data(with: dic)
            var request = URLRequest(url: url)
            
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = postBody
            
            Session.default.request(request).responseJSON {(res) in
                print(res)
                if let response = res.value as? NSDictionary, let txhash = response["hash"]  as? String {
                    //success
                    resolver.fulfill(txhash)
                }
                else {
                    let error = NSError(domain: "requestBindCIpal-fail", code: 22, userInfo: nil)
                    resolver.reject(error)
                }
            }
        }
        return _promise;
    }
}
