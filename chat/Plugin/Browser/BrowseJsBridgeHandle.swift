  
  
  
  
  
  
  

import UIKit
import WebKit
import SBJson5
import SwiftyJSON

fileprivate let JavaScriptCallBackName = "window.nchsdk.bridge.rspCallBack"

class BrowserJsBridgeHandle: NSObject, WKScriptMessageHandler {
    
    fileprivate var mapper = [String:Selector]()
    weak var webView : WKWebView?
    
    override init() {
        super.init()
        configMapper()
    }
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    fileprivate func configMapper() {
        mapper["bridgeOk"] = #selector(bridgeOk)
        mapper["authLogin"] = #selector(authLogin(_:))
        mapper["testInterface"] = #selector(testInterface(_:))
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.description)
        let body = message.body
        let name = message.name
        DispatchQueue.main.async {
            if let selector = self.selectorForName(name) {
                self.perform(selector, with: body)
            }
        }
    }
    
      
    func supportApisName() -> [String] {
        return Array(mapper.keys)
    }
    
    func selectorForName(_ str: String) -> Selector? {
        let selector = mapper[str]
        return selector
    }
    
      
    @objc func bridgeOk() {
        
    }
    
    /*
     ▿ 1 element
     ▿ 0 : 2 elements
     - key : body
     ▿ value : 2 elements
     ▿ 0 : 2 elements
     - key : callback
     - value : _callback_157907347544641254
     ▿ 1 : 2 elements
     - key : params
     - value : canshu
     */
    @objc func testInterface(_ para: Any) {
        if let wrapper = self.wrapperInterfacePara(para) {
            let jscallback = "\(JavaScriptCallBackName)('\(wrapper.callName)','result')"
            self.webView?.evaluateJavaScript(jscallback, completionHandler: nil)
        }
    }
    
    
    @objc func authLogin(_ para: Any) {
        var callbackName: String = ""
        _ = Observable<Bool>.create { (observer) -> Disposable in
            
              
            guard let wrapper = self.wrapperInterfacePara(para) else {
                observer.onError(NSError(domain: "error format", code: 1, userInfo: nil))
                return Disposables.create()
            }
            callbackName = (wrapper.callName as? String) ?? ""
              
            guard let unpack = wrapper.para as? NSDictionary else {
                observer.onError(NSError(domain: "error format", code: 1, userInfo: nil))
                return Disposables.create()
            }
            let verify = self.verifyJsParams(unpack)
            guard verify.isValid == true else {
                observer.onError(NSError(domain: "error params", code: verify.status, userInfo: nil))
                return Disposables.create()
            }
            
              
            guard let vc = R.loadSB(name: "Authorize", iden: "AuthorizeVC") as? AuthorizeVC else {
                observer.onError(NSError(domain: "System error".localized(), code: -1, userInfo: nil))
                return Disposables.create()
            }
            vc.requestData = unpack
            vc.cancelAction = {
                observer.onNext(false)
                observer.onCompleted()
            }
            vc.agreeAction = {
                observer.onNext(true)
                observer.onCompleted()
            }
            vc.show()
            return Disposables.create()
        }
        .subscribe(onNext: { [weak self] (r) in
            if r {
                  
                  
                  
                  
                  
                
                let publicKey = CPAccountHelper.loginUser()?.publicKey ?? ""
                let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
                
                let contentHash = "\(timestamp)".data(using: String.Encoding.utf8)?.sha256()
                let signature = OC_Chat_Plugin_Bridge.signedLoginUser(toContentHash: contentHash)?.toHexString() ?? ""
                
                
                var body = ["publicKey":publicKey,"timestamp":"\(timestamp)","signature":signature]
                var result :[String : Any] = ["status" : 0, "result" : body]
                self?.rspCallWebJs(callBackBody: result, callbackName:callbackName)
            } else {
                  
                var result :[String : Any] = ["status" : 5, "result" : "user reject"]
                self?.rspCallWebJs(callBackBody: result, callbackName:callbackName)
            }
            },
                   onError: { [weak self] (error) in
                    let errorCode = (error as? NSError)?.code ?? 1
                    var result :[String : Any] = ["status" : errorCode, "result" : "error occurred"]
                    self?.rspCallWebJs(callBackBody: result, callbackName:callbackName)
            }
        )
    }
    
    
      
    fileprivate func rspCallWebJs(callBackBody: Any, callbackName: String) {
        let writer:SBJson5Writer = SBJson5Writer.writer(withMaxDepth: 20, humanReadable: false, sortKeys: true) as! SBJson5Writer
        let jsonStr = writer.string(with: callBackBody) ?? ""
        
        let jscallback = "\(JavaScriptCallBackName)(\'\(callbackName)\',\'\(jsonStr)\')"
        self.webView?.evaluateJavaScript(jscallback, completionHandler: nil)
    }
    
      
      
      
    fileprivate func verifyJsParams(_ dic: NSDictionary) -> (isValid: Bool, status: Int, msg: String?) {
        let json = JSON(dic)
        
          
        let timestamp = json["timestamp"].uInt64Value
        let now = UInt64(Date().timeIntervalSince1970 * 1000)
        var diff = now - timestamp
        diff = UInt64(fabs(Double(diff)))
  
        #if !DEBUG
        if  diff > 1 * 60 * 1000 {
            return (false,3,nil)
        }
        #endif
        
          
        guard let publicKey = json["publicKey"].string else {
            return (false,4,nil)
        }
        guard let unzipPubkey = OC_Chat_Plugin_Bridge.unCompressedHexStrPubkey(ofCompressHexPubkey: publicKey) else {
            return (false,4,nil)
        }
        
          
        guard let signature = json["signature"].string else {
            return (false,2,nil)
        }
        guard signature.count == 128 else {
            return (false,2,nil)
        }
        
        let contentHash = "\(timestamp)".data(using: String.Encoding.utf8)?.sha256()
        guard let recoveryPubkey = OC_Chat_Plugin_Bridge.recoveryHexPubkey(forSign64: signature, contentHash: contentHash, judgeHexPubkey: unzipPubkey) else {
            return (false,2,nil)
        }
        guard recoveryPubkey == unzipPubkey else {
            return (false,2,nil)
        }
        return (true, 0, nil)
    }
    
    fileprivate func wrapperInterfacePara(_ para: Any) -> (callName: Any, para: Any)?  {
        if let dic = para as? NSDictionary,
            let body = dic["body"] as? NSDictionary {
            let callbackName = body["callback"] ?? ""
            let params = body["params"] ?? ""
            print("js pass params \(params)")
            return (callbackName, params)
        }
        return nil
    }
}
