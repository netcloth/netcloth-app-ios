//
//  NetWorkCheck.swift
//  chat-plugin
//
//  Created by Grand on 2019/9/29.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import Alamofire

@objc public
class NetWorkCheck: NSObject {
    
    lazy var netmanager = {  () -> NetworkReachabilityManager? in 
        let nm = NetworkReachabilityManager()
        return nm
    }()
    
    @objc public
    var netOk: Bool = false
    
    @objc public
    func check() {
        netmanager?.startListening(onUpdatePerforming: { (status:NetworkReachabilityManager.NetworkReachabilityStatus) in
            switch status {
            case .unknown,
                 .notReachable:
                self.netOk = false
            default:
                self.netOk = true
            }
        })
    }
}
