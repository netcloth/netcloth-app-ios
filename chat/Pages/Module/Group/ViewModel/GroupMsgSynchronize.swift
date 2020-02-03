  
  
  
  
  
  
  

import Foundation

  
class GroupMsgSynchronize : NSObject {
    
    typealias Rsp = (errorCode: Int, ser_rsp_begin_id: Int64, ser_rsp_end_id: Int64)
    
      
    var timer: Timer?
    
      
    var kDiff: Int64 = 5
    
      
    var top_msg_id: Int64 = 0
    
      
    var anchor_open_msg_Id: Int64
    
      
    var const_open_msg_id: Int64 = 0
    
      
    var middle_msg_id: Int64 = 0
    
      
    var anchor_middle_msg_id: Int64 = 0
    
      
    var bottom_msg_id: Int64 = 0
    
      
    var anchor_bottom_msg_id: Int64 =  0
    
      
      
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
    
    
      
    func resetStart(openMsgId: Int64) {
        anchor_open_msg_Id = openMsgId
        configInit()
    }
    
      
      
      
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
                      
                    let remainC = max((bodyRemainC + arrayC - 1) , 0)
                    self?.unreadCountCallBack?(Int64(remainC))
                }
            }
            return Disposables.create()
        }
    }
    
      
      
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

