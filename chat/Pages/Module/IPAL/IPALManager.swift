  
  
  
  
  
  
  

import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire
import SBJson5
import YYKit

class IPALManager: NSObject {
    static let shared = IPALManager()
    
    var toast: ConnectToast?
    var canShow: Bool = true
    
      
    var store: IpalStatus = IpalStatus()
    
    
    func resetForLogin() {
        self.canShow = true
        self.store = IpalStatus()
        self.toast = nil
    }
    
      
    deinit {
        print("dealloc \(type(of: self))")
    }
    
      
    func onStep1_QueryInfo() {        
        if self.canShow == false {
            return
        }
        self.showToast(step: .C_1)
        ChainService.requestLastRegisterInfo().done { (address) in
            if address == nil {
                self.onRequestAllIpalNode(hidToast: true, address: nil)
            } else {
                self.onRequestAllIpalNode(hidToast: false, address: address)
            }
        }
        .catch { error in
            print("ipal " + error.localizedDescription)
            self.showToast(step: .F_1_1)
            self.store.isSeedError = true
            NotificationCenter.default.post(name: NSNotification.Name.serviceConnectStatusChange, object: nil)
            self.toast?.onBackTap = { [weak self] in
                self?.hideToast(nextCan: true, completion: nil)
            }
        }
    }
    
    func onRequestAllIpalNode(hidToast:Bool, address: String?) {
          
        if hidToast {
            self.hideToast(nextCan: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15, execute: {
                    self.showSweetAlert()
                })
            }
        }
        else {
            self.onStep3_decodeService(address: address!)
        }
    }
    
      
    func onStep2_BindNode(_ node: IPALNode) {
        self.showToast(step: .C_2)
        ChainService.requestBindCIpal(node: node).done({ (txHash) in
            node.isClaimOk = 0
            self.store.currentCIpal = node
              
            CPAssetHelper.insertCipalHistroy(txHash,
                                             moniker: node.moniker,
                                             server_address: node.operator_address,
                                             chain_status: 0,
                                             callback: { (r, msg) in
                                                
                                                if let vc = R.loadSB(name: "IPALResult", iden: "ClaimResponseVC") as? ClaimResponseVC {
                                                    vc.txHash = txHash
                                                    Router.pushViewController(vc: vc)
                                                }
                                                let endpoint = node.cIpalEnd()?.endpoint
                                                assert(endpoint != nil)
                                                self.onStep2_AWaitQueryInfo(txHash: txHash)
            })
        })
        .catch { (err) in
            self.showToast(step: .F_2_1)
            self.toast?.onRetryTap = { [weak self] in
                self?.onStep2_BindNode(node)
            }
            self.toast?.onSwitchCIpalTap = { [weak self] in
                self?.hideToast(nextCan: true, completion: {
                    if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
                        Router.pushViewController(vc: vc, animate: true, checkSameClass: true)
                    }
                });
            }
        }
    }
    
    func onQueryBlockStatusInfo(txHash: String, requestCount: Int, complete completeHandle: ((Bool) -> Void)? = nil) {
        let path = APPURL.Chain.QueryBlockHashStatus.replacingOccurrences(of: "{tx_hash}", with: txHash)
        NW.requestUrl(path: path, method: .get, para: nil) { (r, res) in
            if r == true && ((res as? NSDictionary) != nil) {
                let json = JSON(res)
                if  json["logs"][0]["success"].boolValue == true {
                    CPAssetHelper.updateChain_status(1, whereTxHash: txHash, callback: nil)
                    completeHandle?(true)
                } else {
                    CPAssetHelper.updateChain_status(2, whereTxHash: txHash, callback: nil)
                    completeHandle?(false)
                    PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "cipal_notify_fail".localized())
                }
            }
            else {
                if requestCount > 10 {
                    CPAssetHelper.updateChain_status(2, whereTxHash: txHash, callback: nil)
                    completeHandle?(false)
                    PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "cipal_notify_fail".localized())
                    return
                }
                
                let diff = 6
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(integerLiteral: diff)) { [weak self] in
                    self?.onQueryBlockStatusInfo(txHash: txHash, requestCount: requestCount + 1, complete: completeHandle)
                }
            }
        }
    }
    
    var Rand_id:Int = 0
    func onStep2_AWaitQueryInfo(txHash: String) {
        self.showToast(step: .C_2)
        Rand_id += 1
        
        let curRand = Rand_id
        
          
        let errorBlock = {
            self.showToast(step: .F_2_1)
            self.toast?.onRetryTap = { [weak self] in
                self?.onStep2_AWaitQueryInfo(txHash: txHash)
            }
            self.toast?.onSwitchCIpalTap = { [weak self] in
                self?.hideToast(nextCan: true, completion: {
                    if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
                        Router.pushViewController(vc: vc, animate: true, checkSameClass: true)
                    }
                });
            }
            self.store.currentCIpal?.isClaimOk = 2
            NotificationCenter.default.post(name: NSNotification.Name.serviceConnectStatusChange, object: nil)
        }
        
        self.onQueryBlockStatusInfo(txHash: txHash, requestCount: 0) { (result) in
              
            if curRand != self.Rand_id {
                return
            }
            
              
            ChainService.requestLastRegisterInfo().done { (address) in
                if address == nil {
                      
                    errorBlock()
                } else {
                    CPAccountHelper.disconnect()
                    self.onStep3_decodeService(address: address!)
                }
            }
            .catch { error in
                errorBlock()
            }
        }
    }
    
      
      
      
    func onStep3_decodeService(address: String) {
        self.showToast(step: .C_2)
        ChainService.queryServerNodeByAddress(server_address: address).done { (node) in
            node.isClaimOk = 1
            self.store.currentCIpal = node
            let endpoint = (node.cIpalEnd()?.endpoint)!
            self.onStep3_ConnectChatService(endPoint: endpoint)
            CPAccountHelper.setNetworkEnterPoint(self.store.currentCIpal?.cIpalEnd()?.endpoint ?? "")
        }.catch { (err) in
            self.showToast(step: .F_2_1)
            self.toast?.onRetryTap = { [weak self] in
                self?.onStep3_decodeService(address: address)
            }
            self.toast?.onSwitchCIpalTap = { [weak self] in
                self?.hideToast(nextCan: true, completion: {
                    if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
                        Router.pushViewController(vc: vc, animate: true, checkSameClass: true)
                    }
                });
            }
        }
    }
    
      
    func onStep3_ConnectChatService(endPoint: String) {
        self.showToast(step: .C_3)
        ChatService.requestLoadBalancing(endPoint: endPoint).done { (node) in
            self.onConnectChatAllPoints(point: node)
        }.catch { (err) in
            self.showToast(step: .F_3_1)
            self.toast?.onRetryTap = { [weak self] in
                self?.onStep3_ConnectChatService(endPoint: endPoint)
            }
            self.toast?.onSwitchCIpalTap = { [weak self] in
                self?.hideToast(nextCan: true, completion: {
                    if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
                        Router.pushViewController(vc: vc, animate: true, checkSameClass: true)
                    }
                });
            }
        }
    }
    
      
    func onConnectChatAllPoints(point: [String]) {
        self.showToast(step: .C_3)
        ChatService.connectChatServer(allEndPoints: point).done { (result) in
            if result == true {
                self.showToast(step: .C_3_1)
                self.toast?.onEnterpriseTap = { [weak self] in
                    self?.hideToast(nextCan: false, completion: nil)
                }
            }
        }.catch { (err) in
            self.showToast(step: .F_3_1)
            self.toast?.onRetryTap = { [weak self] in
                self?.onConnectChatAllPoints(point: point)
            }
            self.toast?.onSwitchCIpalTap = { [weak self] in
                self?.hideToast(nextCan: true, completion: {
                    if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
                        Router.pushViewController(vc: vc, animate: true, checkSameClass: true)
                    }
                });
            }
        }
    }
    
    
    
      
    func showToast(step: ConnectToast.Step) {
        if self.toast == nil {
            self.toast = R.loadNib(name: "ConnectToast") as? ConnectToast
        }
        if let alert = self.toast , canShow {
            Router.showAlert(view: alert)
            canShow = false
        }
        self.toast?.curStep = step
    }
    
    func hideToast( nextCan:Bool = false, completion: (() -> Void)? = nil) {
        self.canShow = nextCan
        Router.rootVC?.dismiss(animated: false, completion: {
            completion?()
        })
    }
    
    func showSweetAlert() {
        guard let alert = R.loadNib(name: "OneButtonAlert") as? OneButtonAlert else {
            return
        }
        alert.titleLabel?.text = "Tips_Title".localized()
        alert.msgLabel?.text = "Tips_Msg".localized()
        alert.okButton?.setTitle("Tips_Ok".localized(), for: .normal)
        
        let vc = NCAlertViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.addContent(view: alert)
        
        Router.rootVC?.present(vc, animated: true, completion: nil)
        
        alert.okBlock = { [weak self] in
            
            if let vc = R.loadSB(name: "IPAL", iden: "IPALIndexVC") as? IPALIndexVC {
                Router.pushViewController(vc: vc)
            }
        }
    }
    
    
      
    func  v2_getIPALStatusInfo(txHash: String,
                               requestCount: Int,
                               autoUpdateDB: Bool = false,
                               stop: UnsafeMutablePointer<Bool>,
                               complete completeHandle: ((Bool) -> Void)? = nil) {
        
        if stop.pointee == true {
            return
        }
        let path = APPURL.Chain.QueryBlockHashStatus.replacingOccurrences(of: "{tx_hash}", with: txHash)
        NW.requestUrl(path: path, method: .get, para: nil) { [stop] (r, res) in
            if stop.pointee == true {
                return
            }
            
            if r == true && ((res as? NSDictionary) != nil) {
                let json = JSON(res)
                if  json["logs"][0]["success"].boolValue == true {
                    if autoUpdateDB {
                        CPAssetHelper.updateChain_status(1, whereTxHash: txHash, callback: nil)
                    }
                    completeHandle?(true)
                } else {
                    if autoUpdateDB {
                        CPAssetHelper.updateChain_status(2, whereTxHash: txHash, callback: nil)
                        PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "cipal_notify_fail".localized())
                    }
                    completeHandle?(false)
                }
            }
            else {
                if requestCount > 20 {
                    if autoUpdateDB {
                        CPAssetHelper.updateChain_status(2, whereTxHash: txHash, callback: nil)
                        PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "cipal_notify_fail".localized())
                    }
                    completeHandle?(false)
                    return
                }
                
                let diff = 3
                DispatchQueue.main.asyncAfter(deadline: DispatchTime(integerLiteral: diff)) { [weak self, stop] in
                    self?.v2_getIPALStatusInfo(txHash: txHash, requestCount: requestCount + 1, autoUpdateDB: autoUpdateDB, stop: stop, complete: completeHandle)
                }
            }
        }
    }

}

extension String {
    
    func nonWhiteAndNewLines() -> String {
        var a = self.replacingOccurrences(of: " ", with: "")
        a = a.replacingOccurrences(of: "\n", with: "")
        return a
    }
}


extension DispatchTime: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }
}

extension DispatchTime: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }
}
