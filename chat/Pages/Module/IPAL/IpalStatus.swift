//
//  ipalStatus.swift
//  chat
//
//  Created by Grand on 2019/11/9.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

typealias EnterPoint = [IPALNode]

/// eg: store
class IpalStatus: NSObject {
    //current register cipal
    @objc dynamic var oldCIpal: IPALNode?
    
    var isSeedError: Bool?
    
    @objc dynamic var currentCIpal: IPALNode? {
        willSet {
            oldCIpal = self.currentCIpal
            isSeedError = false
        }
        didSet {
            self.findCurAIpalNode { (node) in
                if node != nil {
                    self.curAIPALNode = node
                }
                else if node == nil,
                    let _ = self.currentCIpal?.aIpal() {
                     self.curAIPALNode = self.currentCIpal
                }
            }
        }
    }
    
    fileprivate var _curAIPALNode: IPALNode?
    @objc dynamic var curAIPALNode: IPALNode? {
        set {
            _curAIPALNode = newValue
        }
        get {
            return _curAIPALNode
        }
    }
    public func findCurAIpalNode(complete: ((IPALNode?) -> Void)?) {
        if _curAIPALNode != nil {
            complete?(_curAIPALNode)
        }
        else {
            CPAssetHelper.getAIPALHistoryLimited({ (list) in
                if let chaim = list?.first {
                    ChainService.requestAllChatServer().done { (list:[IPALNode]) in
                        var chatEnters: [IPALNode] = []
                        chatEnters = InnerHelper.filterAIPALs(list: list)
                        for node in chatEnters {
                            if node.operator_address == chaim.operator_address {
                                complete?(node)
                                self._curAIPALNode = node
                                return
                            }
                        }
                        //error
                        complete?(nil)
                    }
                    .catch { (err) in
                        let tmpNode =  self.asAipalNode(claim: chaim)
                        complete?(tmpNode)
                        self._curAIPALNode = tmpNode
                    }
                }
                else {
                    complete?(nil)
                }
            })
        }
    }
    
    //MARK:- Helper
    
    fileprivate func asAipalNode(claim: CPChainClaim) -> IPALNode {
        let node = IPALNode()
        node.operator_address = claim.operator_address
        node.moniker = claim.moniker
        let service = IPALServiceAddress()
        service.type = "3"
        service.endpoint = claim.endpoint
        node.endpoints = [service]
        return node
    }
   
}
