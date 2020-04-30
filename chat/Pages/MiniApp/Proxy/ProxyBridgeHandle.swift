







import Foundation

class ProxyBridgeHandle : BrowserJsBridgeHandle {
    override func configMapper() {
        super.configMapper()
        mapper["setProxy"] = #selector(setProxy(_:))
        mapper["revertProxy"] = #selector(revertProxy(_:))
        mapper["getProxy"] = #selector(getProxy(_:))
    }
    
    
    /*
     envStatus: {
             0: "OK",
             1: "unknow error",
             2: "set proxy failed",
             3: "user reject to set proxy",
             4: "no proxy"
     }
     */
    
    @objc func setProxy(_ para: Any) {
        guard let wrapper = self.wrapperInterfacePara(para) else {
            return
        }
        
        var body = ""
        var result :[String : Any] = ["status" : 0, "result" : body]
        let callname = (wrapper.callName as? String) ?? ""
                
        if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
            
            alert.msgLabel?.text = "Activate the Proxy".localized()
            alert.titleLabel?.isHidden = true
            
            alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            
            alert.cancelBlock = { [weak self] in
                result["status"] = 3
                self?.rspCallWebJs(callBackBody: result, callbackName: callname)
            }
            alert.okBlock = { [weak self] in
                self?.rspCallWebJs(callBackBody: result, callbackName: callname)
                
                let json = JSON(wrapper.para)
                let host = json["host"].stringValue
                let port = json["port"].intValue
                
                NCUserCenter.shared?.proxy.change(commit: { (store) in
                    store.openProxy = true
                    store.host = host
                    store.port = port
                })
                
            }
            Router.showAlert(view: alert)
        }
        else {
            result["status"] = 1
            self.rspCallWebJs(callBackBody: result, callbackName: callname)
        }
    }
    
    
    
    @objc func revertProxy(_ para: Any) {
        guard let wrapper = self.wrapperInterfacePara(para) else {
            return
        }
        
        var body = ""
        var result :[String : Any] = ["status" : 0, "result" : body]
        let callname = (wrapper.callName as? String) ?? ""
        self.rspCallWebJs(callBackBody: result, callbackName: callname)
        
        NCUserCenter.shared?.proxy.change(commit: { (store) in
            store.openProxy = false
            store.host = ""
            store.port = 0
        })
    }
    
    
    @objc func getProxy(_ para: Any) {
        guard let wrapper = self.wrapperInterfacePara(para) else {
            return
        }
        
        let callname =  (wrapper.callName as? String) ?? ""
        if NCUserCenter.shared?.proxy.value.openProxy == true {
            let host = NCUserCenter.shared?.proxy.value.host ?? ""
            let port = NCUserCenter.shared?.proxy.value.port ?? 0
            var body = ["host":host,"port":port] as [String : Any]
            var result :[String : Any] = ["status" : 0, "result" : body]
            self.rspCallWebJs(callBackBody: result, callbackName: callname)
        }
        else {
            var result :[String : Any] = ["status" : 4, "result" : ""]
            self.rspCallWebJs(callBackBody: result, callbackName: callname)
        }
    }
    
    
}



