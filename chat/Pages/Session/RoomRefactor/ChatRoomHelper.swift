//
//  ChatRoomHelper.swift
//  chat
//
//  Created by Grand on 2020/4/2.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class ChatRoomHelper: NSObject, ChatDelegate {
    /// 正在撤销 // just tip
    @IBOutlet weak var recallOnGoingContainer: UIControl?
    /// 提示撤销失败
    @IBOutlet weak var recallFailTipControl: UIControl?
    
    @IBOutlet weak var p2pRoom: ChatRoomVC?
    @IBOutlet weak var groupRoom: GroupRoomVC?
    
    var inRetryRecall = false {
        didSet {
            onHandleChange()
        }
    }
    
    /// 当前群聊的失败的业务订单号
    fileprivate var fail_order: NCProtoQueryRecallStatusRsp? {
        didSet {
            onHandleChange()
        }
    }
    
    fileprivate let disbag = DisposeBag()
    deinit {
        print("dealloc \(type(of: self))")
        CPChatHelper.removeInterface(self)
    }
    override init() {
        super.init()
        print("\(type(of: self)) init")
    }
    
    func vc_viewDidLoad() {
        
        resetHide()
        configEvent()
        
        if p2pRoom != nil {
            fetchRoomFailMsg_p2p()
        }
        else if groupRoom != nil {
            fetchRoomFailMsg_group()
        }
    }
    
    fileprivate func configEvent() {
        CPChatHelper.addInterface(self)
        
        self.recallFailTipControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onActionRetry()
        }).disposed(by: disbag)
    }
    
    fileprivate func onHandleChange() {
        if self.inRetryRecall {
            self.recallOnGoingContainer?.isHidden = false
            self.recallFailTipControl?.isHidden = true
        }
        else if self.fail_order != nil {
            self.recallOnGoingContainer?.isHidden = true
            self.recallFailTipControl?.isHidden = false
        }
        else {
            self.recallOnGoingContainer?.isHidden = true
            self.recallFailTipControl?.isHidden = true
        }
    }
    
    fileprivate func onActionRetry() {
        
    }
    
    //MARK:- Innerface
    func onRecallSuccessNotify(_ successNotify: NCProtoNetMsg) {
        guard let body = try? NCProtoRecallMsgNotify.parse(from: successNotify.data_p) else {
            return
        }
        if shouldRecieve(msg: successNotify, chatType: body.chatType) {
            deleteChatMsg_p2p(msg: successNotify, body: body)
            deleteChatMsg_group(msg: successNotify, body: body)
            self.inRetryRecall = false
            self.fail_order = nil
        }
    }
    
    func onRecallFailedNotify(_ failNotify: NCProtoNetMsg) {
        guard let body = try? NCProtoRecallMsgFailedNotify.parse(from: failNotify.data_p) else {
            return
        }
        if shouldRecieve(msg: failNotify, chatType: body.chatType) {
            self.inRetryRecall = false
        }
    }
        
    //MARK:- Helper
    fileprivate func shouldRecieve(msg: NCProtoNetMsg, chatType: NCProtoChatType) -> Bool {
        let fromPubkey = msg.head.fromPubKey.cpToHexString()
        let toPubkey = msg.head.toPubKey.cpToHexString()
        if chatType == NCProtoChatType.chatTypeSingle {
            if fromPubkey == CPAccountHelper.loginUser()?.publicKey {
                return true
            } else if (fromPubkey == self.p2pRoom?.toPublicKey) {
                return true
            }
        }
        else if chatType == NCProtoChatType.chatTypeGroup {
            if toPubkey == self.groupRoom?.roomService?.chatContact?.value.publicKey {
                return true
            }
        }
        
        return false
    }
    
    fileprivate func deleteChatMsg_p2p(msg: NCProtoNetMsg , body:NCProtoRecallMsgNotify) {
        guard let p2pVC = self.p2pRoom else {
            return
        }
        let fromPubkey = msg.head.fromPubKey.cpToHexString()
        let toPubkey = msg.head.toPubKey.cpToHexString()
        let time = Double(body.timestamp) / 1000.0
        p2pVC.msgPatchQueue.async { [weak p2pVC] in
            p2pVC?.messageArray.removeAll(where: { (tmp) -> Bool in
                if tmp.senderPubKey == fromPubkey &&
                    tmp.toPubkey == toPubkey &&
                    tmp.createTime <= time {
                    return true
                }
                return false
            })
            p2pVC?._refreshVisibleCells()
        }
    }
    fileprivate func deleteChatMsg_group(msg: NCProtoNetMsg , body:NCProtoRecallMsgNotify) {
        guard let groupVC = self.groupRoom else {
            return
        }
        let fromPubkey = msg.head.fromPubKey.cpToHexString()
        let toPubkey = msg.head.toPubKey.cpToHexString()
        let time = Double(body.timestamp) / 1000.0
        groupVC.msgPatchQueue.async { [weak groupVC] in
            groupVC?.messageArray.removeAll(where: { (tmp) -> Bool in
                if tmp.senderPubKey == fromPubkey &&
                    tmp.toPubkey == toPubkey &&
                    tmp.createTime <= time {
                    return true
                }
                return false
            })
            groupVC?._refreshVisibleCells()
        }
    }
    
    //MARK:-
    fileprivate func getChatToPubkey() -> String {
        var topubkey = self.p2pRoom?.toPublicKey ?? ""
        if topubkey.isEmpty == false {
            return topubkey
        }
        topubkey = self.groupRoom?.roomService?.chatContact?.value.publicKey ?? ""
        if topubkey.isEmpty == false {
            return topubkey
        }
        return ""
    }
    
    fileprivate func resetHide() {
        recallOnGoingContainer?.isHidden = true
        recallFailTipControl?.isHidden = true
    }
    
    fileprivate func fetchRoomFailMsg_p2p() {
        
        
    }
    
    fileprivate func fetchRoomFailMsg_group() {
        
    }
    
    fileprivate func onFetchHandle(rsp: NCProtoQueryRecallStatusRsp?) {
        guard let back = rsp else {
            return
        }
        if back.outTradeNo.isEmpty == false &&
            (back.bizStatus == NCProtoOrderBizStatus.orderBizStatusFailed ||
                back.bizStatus == NCProtoOrderBizStatus.orderBizStatusUnspecified) {
            self.fail_order = back
        }
        else if back.outTradeNo.isEmpty == true
            && back.bizStatus == NCProtoOrderBizStatus.orderBizStatusUnspecified {
            //Todo 支付成功，上报失败 -- 无记录  issuee
            self.patchFixOrderDetail()
        }
        if inRetryRecall &&
            (self.fail_order != nil) {
            self.onActionRetry()
        }
    }
    //MARK:-
    fileprivate func patchFixOrderDetail() {
        
    }
}
