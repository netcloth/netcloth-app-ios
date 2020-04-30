//
//  GroupDistinctSenderVC.swift
//  chat
//
//  Created by Grand on 2019/12/26.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class GroupDistinctSenderVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var confirmAllBtn: UIButton?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var headerV: UIView?
    
    var groupContact: CPContact?
    
    fileprivate let disbag = DisposeBag()
    
    //MARK:- Private
    fileprivate var dataArray: [CPGroupNotify]? {
        didSet {
            var count = 0
            if let array = self.dataArray {
                for item in array {
                    if item.status.rawValue == DMNotifyStatus.unread.rawValue ||
                        item.status.rawValue == DMNotifyStatus.read.rawValue {
                        count += 1
                    }
                }
                allUnreadCount = count
            }
        }
    }
    
    fileprivate var allUnreadCount: Int = 0 {
        didSet {
            let groupName = groupContact?.remark ?? ""
            let count = self.allUnreadCount
            if count == 0 {
                self.title = groupName
                headerV?.isHidden = true
            } else {
                self.title = "\(groupName)(\(count))"
                headerV?.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allUnreadCount = 0
        configEvent()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        let sid = self.groupContact?.sessionId ?? 0
        CPGroupManagerHelper.updateGroupNotifyToRead(inSession: sid) { (r, msg) in
            NotificationCenter.post(name: .groupNotifyReadStatusChange)
        }
    }
    
    func loadData() {
        self.showLoading()
        let sid = groupContact?.sessionId ?? 0
        CPGroupManagerHelper.getGroupDistinctSenderOfLatestNotify(inSession: sid) {[weak self] (r, msg, array) in
            self?.dismissLoading()
            self?.dataArray = array
            self?.tableView?.reloadData()
        }
    }
    
    func configEvent() {
        self.confirmAllBtn?.rx.tap.subscribe(onNext: { [weak self] (e) in
            self?.onPassAll()
        }).disposed(by: disbag)
    }
    
    //MARK:- 全部通过
    fileprivate var allPassBag = DisposeBag()
    fileprivate  func onPassAll() {
        guard let array = self.dataArray else {
            return
        }
        
        allPassBag = DisposeBag()
        showLoading()
        var obs = [Observable<Bool>]()
        for item in array {
            if let obser =  self.filfulled(notice: item) {
                obs.append(obser)
            }
        }
        
        if obs.isEmpty {
            dismissLoading()
        }
        else {
            Observable.zip(obs)
                .observeOn(MainScheduler.instance)
                .subscribe { [weak self] (e) in
                    self?.dismissLoading()
            }
        }
    }
    
    fileprivate func filfulled(notice: CPGroupNotify) -> Observable<Bool>? {
        guard let group = self.groupContact,
            notice.status == DMNotifyStatus.unread || notice.status == DMNotifyStatus.read
            else {
                return nil
        }
        
        let groupPrikey = group.decodePrivateKey()
        let groupName = group.remark
        
        return Observable.create { [weak self] (observer) -> Disposable in
            
            let realPass = { (joinMsg: NCProtoNetMsg) in
                CPGroupChatHelper.sendGroupJoinApproved(joinMsg, groupPrivateKey: groupPrikey, groupName: groupName) { [weak self] (response) in
                    let json = JSON(response)
                    if let code = json["code"].int ,
                        (code == ChatErrorCode.OK.rawValue || code == ChatErrorCode.memberDuplicate.rawValue) {
                        notice.status = DMNotifyStatus.fulfilled
                        let memberPubkey = notice.senderPublicKey ?? ""
                        let sid = notice.sessionId ?? 0
                        CPGroupManagerHelper.updateGroupNotify(inSession: sid, ofRequestUser: memberPubkey, to: DMNotifyStatus.fulfilled, callback: nil)
                        observer.onNext(true)
                    }
                    else {
                        observer.onNext(false)
                    }
                }
            }
            
            if notice.join_msg == nil {
                _ = InnerHelper.decode(notice: notice).subscribe(onNext: { (r) in
                    realPass(notice.join_msg!)
                })
            } else {
                realPass(notice.join_msg!)
            }
            
            return Disposables.create()
        }
    }
    
    
    
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath)
        let data = dataArray?[safe: indexPath.row]
        cell.reloadData(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = dataArray?[safe: indexPath.row],
            data.manualDecode == true {
            if let vc = R.loadSB(name: "GroupApproveDetailVC", iden: "GroupApproveDetailVC") as? GroupApproveDetailVC {
                vc.latestNotice = data
                vc.groupContact = self.groupContact
                Router.pushViewController(vc: vc)
            }
        }
        
    }
    
}
