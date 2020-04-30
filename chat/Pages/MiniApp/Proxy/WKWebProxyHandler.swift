//
//  WKWebProxyHandler.swift
//  chat
//
//  Created by Grand on 2020/3/23.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import YYKit

fileprivate var key_proxy_isfail = "key_proxy_isfail"
fileprivate var key_proxy_iscomplete = "key_proxy_iscomplete"

@available(iOS 11.0, *)
///  针对每一个web的
class WKWebProxyHandler: NSObject, WKURLSchemeHandler {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    lazy var afsession: Session = {
        var rootQueue: DispatchQueue = DispatchQueue(label: "org.alamofire.session.rootQueue")
        var delegateQueue:OperationQueue = OperationQueue(maxConcurrentOperationCount: 1, underlyingQueue: rootQueue, name: "org.alamofire.session.sessionDelegateQueue")
        var delegate = SessionDelegate()
        
        /// Note:
        let host = NCUserCenter.shared?.proxy.value.host ?? ""
        let port = NCUserCenter.shared?.proxy.value.port ?? 0
        
        let configuration = URLSessionConfiguration.af.default
        configuration.connectionProxyDictionary = proxyDict(host: host, port: port)
        
        let urlsession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
        return Session(session: urlsession, delegate: delegate, rootQueue: rootQueue)
    }()
    
    //MARK:- Net work Proxy
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("<<< 代理开始 url ", urlSchemeTask.request.url?.absoluteString);
        if isValidTask(urlSchemeTask) == false {
            return
        }
        
        afsession.request(urlSchemeTask.request).responseData { [weak self] (res) in
            print("<<< 代理请求回调");
            if self?.isValidTask(urlSchemeTask) == false {
                return
            }
            
            if let error = res.error {
                urlSchemeTask.didFailWithError(error)
                self?.markFailTask(urlSchemeTask)
                print("<<< 代理失败", error.localizedDescription);
                #if DEBUG
                Toast.show(msg: "System error".localized())
                #endif
            }
            else {
                if let rsp = res.response {
                    urlSchemeTask.didReceive(rsp)
                }
                if let data = res.data {
                    urlSchemeTask.didReceive(data)
                }
                urlSchemeTask.didFinish()
                self?.markCompleteTask(urlSchemeTask)
                print("<<< 代理完成");
            }
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("<<< 代理 Stop");
        markFailTask(urlSchemeTask)
    }
    
    func isValidTask(_ urlSchemeTask: WKURLSchemeTask) -> Bool {
        if let task = urlSchemeTask as? NSObject {
            let isfail = task.getAssociatedValue(forKey: &key_proxy_isfail) as? String
            let iscomplete = task.getAssociatedValue(forKey: &key_proxy_iscomplete) as? String
            if isfail == "1"  || iscomplete == "1" {
                print("<<< 代理异常");
                return false
            }
        }
        return true
    }
    
    func markCompleteTask(_ urlSchemeTask: WKURLSchemeTask) {
        if let task = urlSchemeTask as? NSObject {
            task.setAssociateValue("1", withKey: &key_proxy_iscomplete)
        }
    }
    
    func markFailTask(_ urlSchemeTask: WKURLSchemeTask) {
        if let task = urlSchemeTask as? NSObject {
            task.setAssociateValue("1", withKey: &key_proxy_isfail)
        }
    }
    
    
    //MARK:- Helper
    func proxyDict(host: String, port: Int) -> [String:Any] {
        let proxyDict = [
            kCFNetworkProxiesHTTPEnable as String : true,
            kCFNetworkProxiesHTTPProxy as String: host,
            kCFNetworkProxiesHTTPPort as String: port,
            
            /// kCFNetworkProxiesHTTPSEnable
            "HTTPSEnable" : true,
            "HTTPSProxy" : host,
            "HTTPSPort": port,
            
            /// kCFNetworkProxiesRTSPEnable
            "RTSPEnable" : true,
            "RTSPProxy": host,
            "RTSPPort": port,
            
            /// kCFNetworkProxiesSOCKSEnable
            "SOCKSEnable" : true,
            "SOCKSProxy" : host,
            "SOCKSPort" : port
            ] as [String : Any]
        
        return proxyDict
    }
}



extension OperationQueue {
    /// Creates an instance using the provided parameters.
    ///
    /// - Parameters:
    ///   - qualityOfService:            `QualityOfService` to be applied to the queue. `.default` by default.
    ///   - maxConcurrentOperationCount: Maximum concurrent operations.
    ///                                  `OperationQueue.defaultMaxConcurrentOperationCount` by default.
    ///   - underlyingQueue: Underlying  `DispatchQueue`. `nil` by default.
    ///   - name:                        Name for the queue. `nil` by default.
    ///   - startSuspended:              Whether the queue starts suspended. `false` by default.
    convenience init(qualityOfService: QualityOfService = .default,
                     maxConcurrentOperationCount: Int = OperationQueue.defaultMaxConcurrentOperationCount,
                     underlyingQueue: DispatchQueue? = nil,
                     name: String? = nil,
                     startSuspended: Bool = false) {
        self.init()
        self.qualityOfService = qualityOfService
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.underlyingQueue = underlyingQueue
        self.name = name
        isSuspended = startSuspended
    }
}

extension WKWebViewConfiguration {
    class func proxyConifg() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        
        if #available(iOS 11.0, *) {
            let handler = WKWebProxyHandler()
            config.setURLSchemeHandler(handler, forURLScheme: "http")
            config.setURLSchemeHandler(handler, forURLScheme: "https")
            config.setURLSchemeHandler(handler, forURLScheme: "ws")
            config.setURLSchemeHandler(handler, forURLScheme: "socks5")
        } else {
            // Fallback on earlier versions
        }
        return config
    }
    
    func revertProxy() {
        if #available(iOS 11.0, *) {
            
            guard self.urlSchemeHandler(forURLScheme: "http") != nil else {
                return
            }
            
            self.setURLSchemeHandler(nil, forURLScheme: "http")
            self.setURLSchemeHandler(nil, forURLScheme: "https")
            self.setURLSchemeHandler(nil, forURLScheme: "ws")
            self.setURLSchemeHandler(nil, forURLScheme: "socks5")
        } else {
            // Fallback on earlier versions
        }
    }
    
    func resumeProxy() {
        if #available(iOS 11.0, *) {
            guard self.urlSchemeHandler(forURLScheme: "http") == nil else {
                return
            }
            let handler = WKWebProxyHandler()
            self.setURLSchemeHandler(handler, forURLScheme: "http")
            self.setURLSchemeHandler(handler, forURLScheme: "https")
            self.setURLSchemeHandler(handler, forURLScheme: "ws")
            self.setURLSchemeHandler(handler, forURLScheme: "socks5")
        } else {
            // Fallback on earlier versions
        }
    }
}
