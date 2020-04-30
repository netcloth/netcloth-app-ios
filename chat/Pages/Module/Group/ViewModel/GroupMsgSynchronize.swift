//
//  GroupRoomMsgSysManage.swift
//  chat
//
//  Created by Grand on 2019/12/16.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

/// 群消息同步管理器 V2
class GroupMsgSynchronize : NSObject {
    
    typealias Rsp = (errorCode: Int, ser_rsp_begin_id: Int64, ser_rsp_end_id: Int64)
    
    /// 防止tcp不返回
    var timer: Timer?
    
    //根据last_big_serverId 计算 每5个拉取
    var kDiff: Int64 = 5
    
    // 从middle 开始， 向上 (0, top)
    var top_msg_id: Int64 = 0
    
    //MARK: 打开room 时候，携带进入的。 从open_last_msg_Id 开始 （多少条未读）
    var anchor_open_msg_Id: Int64
    
    /// init 携入，不再变化
    var const_open_msg_id: Int64 = 0
    
    ///  (anchor_open_msg_Id , middle_msg_id)
    var middle_msg_id: Int64 = 0
    
    /// 锚点 计算得到 固定不变
    var anchor_middle_msg_id: Int64 = 0
    
    ///  (anchor_middle_msg_id  bottom_msg_id)
    var bottom_msg_id: Int64 = 0
    
    /// 锚点 请求获取 固定不变
    var anchor_bottom_msg_id: Int64 =  0
    
    //MARK:- Life Cycle
    /// 自己的状态
    var inFetching: Bool = true
    
    var unreadCountCallBack: ((Int64) -> Void)?
    
    weak var roomVC: GroupRoomVC!
    required init(room: GroupRoomVC, openMsgId: Int64) {
        roomVC = room
        anchor_open_msg_Id = openMsgId
        const_open_msg_id = openMsgId
        super.init()
        
        configInit(callUnreadCount: true)
    }
    
    var disbag = DisposeBag()
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    
    //MARK:- Public
    func resetStart(openMsgId: Int64) {
        anchor_open_msg_Id = openMsgId
        configInit()
    }
    
    /// (0, top_msg_id)
    /// (anchor_open_msg_Id , middle_msg_id)
    /// (anchor_middle_msg_id  bottom_msg_id)
    func startSys() {
        
        if inFetching {
            print("syn group message startSys inFetching return")
            return
        }
        print("syn group message startSys")
        disbag = DisposeBag()
        inFetching = true
        
        let top = v2_syn(beginId: 0, endId: self.top_msg_id)
        let middle = v2_syn(beginId: self.anchor_open_msg_Id, endId: self.middle_msg_id)
        let bottom = v2_syn(beginId: self.anchor_middle_msg_id, endId: self.bottom_msg_id)
        
        Observable.zip(top, middle, bottom).subscribe(onNext: { [weak self] (arg0) in
            let allback: (GroupMsgSynchronize.Rsp?, GroupMsgSynchronize.Rsp?, GroupMsgSynchronize.Rsp?) = arg0
            if let rsp = allback.0 {
                self?.top_msg_id = rsp.ser_rsp_begin_id
            }
            if let rsp = allback.1 {
                self?.middle_msg_id = rsp.ser_rsp_begin_id
            }
            if let rsp = allback.2 {
                self?.bottom_msg_id = rsp.ser_rsp_begin_id
            }
            self?.inFetching = false
        }).disposed(by: disbag)
        
        startTimer()
    }
    
    //MARK:- Private
    fileprivate func configInit(callUnreadCount: Bool = false) {
        disbag = DisposeBag()
        inFetching = true
        fetchingLastBigMsgId(callUnreadCount: callUnreadCount).subscribe(onNext: { [weak self] (ser_rsp_bid) in
            if let bid = ser_rsp_bid {
                self?.anchor_bottom_msg_id = bid
                self?.calculateAnchorId()
            }
            self?.inFetching = false
            self?.startSys()
        }, onDisposed: {
            print("syn group message disposed 1")
        }).disposed(by: disbag)
        
        startTimer()
    }
    
    fileprivate func calculateAnchorId() {
        let total = self.anchor_open_msg_Id + self.anchor_bottom_msg_id
        let mid = total / 2
        self.anchor_middle_msg_id = mid
        
        self.middle_msg_id = self.anchor_middle_msg_id
        self.bottom_msg_id = self.anchor_bottom_msg_id
        self.top_msg_id = self.anchor_open_msg_Id
    }
    
    /// 获取了最后5个数据
    fileprivate func fetchingLastBigMsgId(callUnreadCount: Bool = false) -> Observable<Int64?> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let prikey = self?.roomVC.roomService?.chatContact?.value.decodePrivateKey() else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let count = self?.kDiff ?? 5
            let lsid = self?.anchor_open_msg_Id ?? 0
            CPGroupChatHelper.sendGroupGetMsgReq(lsid, end: -1, count: UInt32(count), inGroupPrivateKey: prikey) {(body) in
                observer.onNext(body?.beginId)
                observer.onCompleted()
                
                if callUnreadCount {
                    let bodyRemainC = UInt(body?.remainCount ?? 0)
                    let arrayC = body?.msgsArray_Count ?? 0
                    //Note -1
                    let rc = Int(bodyRemainC + arrayC) - 1
                    let remainC = max(rc, 0)
                    self?.unreadCountCallBack?(Int64(remainC))
                }
            }
            return Disposables.create()
        }
    }
    
    //MARK: syn
    // [ 0 100] 传入的大区间 ， 不断修复 endid
    fileprivate func v2_syn(beginId:Int64, endId:Int64) -> Observable<Rsp?> {
        
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let sessionId = self?.roomVC.roomService?.chatContact?.value.sessionId ,
                let prikey = self?.roomVC.roomService?.chatContact?.value.decodePrivateKey() ,
                endId > beginId,
                endId >= 1
                else {
                    print("syn group message v2_syn_error bid \(beginId) eid \(endId)")
                    observer.onNext((0,0,0))
                    observer.onCompleted()
                    return Disposables.create()
            }
            let count = self?.kDiff ?? 0
            
            print("syn group message query local bid \(beginId) eid \(endId)")

            CPGroupManagerHelper.v2_queryMessages(inSession: Int(sessionId), beginId: beginId, endId: endId , count: Int(count)) { (needSyn, realCount, rBid, rEid) in
                if needSyn == false {
                    //本轮 不需要同步
                    print("syn group message local not need  bid \(rBid) eid \(rEid)")
                    observer.onNext((0, rBid == 1 ? 0 : rBid , rEid))
                    observer.onCompleted()
                }
                else {
                    print("syn group message request bid \(beginId) endid \(rEid) count \(UInt32(realCount))")
                    CPGroupChatHelper.sendGroupGetMsgReq(beginId, end: rEid, count: UInt32(realCount), inGroupPrivateKey: prikey) { (body) in
                        let sid = body?.beginId ?? 0
                        let eid = body?.endId ?? 0
                        print("syn group message rsp bid \(sid) eid \(eid)")
                        observer.onNext((0, sid, eid))
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    
    //MARK:- Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.init(timeInterval: 15, block: { [weak self] (t) in
            self?.onTimerFire()
            }, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func onTimerFire() {
        inFetching = false
    }
}

