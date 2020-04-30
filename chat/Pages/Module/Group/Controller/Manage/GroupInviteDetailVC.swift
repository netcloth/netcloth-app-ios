//
//  GroupInviteDetailVC.swift
//  chat
//
//  Created by Grand on 2019/12/9.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit


/// 邀请详情
class GroupInviteDetailVC: BaseViewController {
    
    @IBOutlet weak var smallRemark: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    @IBOutlet weak var memberCountL: UILabel?
    @IBOutlet weak var joinBtn: UIButton?
    
    var msg: CPMessage?  //invite msg source 0
    var qr_groupPublickKey: String? //source 1 二维码邀请，群公钥 方式二 压缩方式(已被解压)
    var recommended_groupPublickKey: String? //群推荐 已被解压 source 2
    var miniLinkGroupId: String? // source 3. 小应用
    
    let disbag = DisposeBag()
    
    private var groupInfo: CPGroupInfoResp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        requestInfo()
    }
    
    fileprivate func configUI() {
        self.joinBtn?.backgroundColor = UIColor(hexString: Color.blue)
    }
    
    //set before
    func configEvent() {
        self.joinBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onJoinTap()
        }).disposed(by: disbag)
    }
    
    //MARK:- Action
    func onJoinTap() {
        guard let response = self.groupInfo else {
            return
        }
        let pubkey = response.group_id
        _ = findGroupContact(groupPubkey: pubkey).subscribe(onNext: { [weak self] (contact) in
            if let find = contact,
                find.groupProgress.rawValue >= GroupCreateProgress.createOK.rawValue {
                Router.dismissVC(animate: false, completion: {
                    if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
                        vc.chatContact = find
                        Router.pushViewController(vc: vc)
                    }
                }, toRoot: true)
            }
            else {
                self?.nextStepJudge()
            }
        })
    }
    
    func nextStepJudge() {
        guard let response = self.groupInfo else {
            return
        }
        let source = getJoinSource()
        if source == 1 {
            //scan qr code
            toSubmitVc()
        }
        else if source == 2 {
            //recommended group
            toSubmitVc()
        }
        else {
            let pubkey = response.group_id
            let groupName = response.name
            
            let inviteType = response.invite_type
            if inviteType == CPGroupInviteType.onlyOwner.rawValue {
                self.sendRealJoin()
            }
            else if inviteType == CPGroupInviteType.needApprove.rawValue {
                toSubmitVc()
            }
            else if inviteType == CPGroupInviteType.allowAll.rawValue {
                self.sendRealJoin()
            }
        }
    }
    
    //MARK:- Helper
    func sendRealJoin() {
        guard let response = self.groupInfo,
            let groupPrikey = getGroupPrivatekey(),
            groupPrikey.count == 32
        else {
                Toast.show(msg: "System error".localized())
                return
        }
        self.showLoading()
        let pubkey = response.group_id
        let nickname = CPAccountHelper.loginUser()?.accountName ?? ""
        let source = getJoinSource()
        let inviter = getInviterHexPubkey()
        let name = response.name
        
        CPGroupChatHelper.sendGroupJoin(nickname,
                                        desc: nil,
                                        source: Int32(source),
                                        inviterPubkey: inviter,
                                        groupPubkey: pubkey) { [weak self] (res) in
            self?.dismissLoading()
            let json = JSON(res)
            let code = json["code"].int
            if (code == ChatErrorCode.OK.rawValue || code == ChatErrorCode.memberDuplicate.rawValue) {
                //add contact , 更新联系人进度
                let notice = self?.groupInfo?.notice["content"] as? String ?? ""
                CPGroupManagerHelper.joinGroup(byGroupName: name, groupPrivateKey: groupPrikey, groupNotice: notice, callback: { (r, msg, contact) in
                    //switch to group chat
                    if let ct = contact , r == true {
                        Router.dismissVC(animate: false, completion: {
                            if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
                                vc.chatContact = ct
                                Router.pushViewController(vc: vc)
                            }
                        }, toRoot: true)
                    }
                })
            }
            else if (code == ChatErrorCode.memberExceed.rawValue) {
                //exceed
                self?.showFailJoinAlert()
            } else {
                //system error
                Toast.show(msg: "System error".localized())
            }
        }
    }
    
    func findGroupContact(groupPubkey: String) -> Observable<CPContact?> {
        return Observable.create { [weak self] (observer) -> Disposable in
            CPContactHelper.getOneContact(byPubkey: groupPubkey) {(r, msg, contact) in
                if let ct = contact,
                    r == true,
                    ct.sessionType == .group {
                    if ct.decodePrivateKey().count == 0 {
                        CPContactHelper.deleteContactUser(groupPubkey, callback: nil)
                        observer.onNext(nil)
                    }
                    else {
                        observer.onNext(ct)
                    }
                }
                else {
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func getInviterHexPubkey() -> String? {
        if let d = self.msg?.senderPubKey {
            return d
        }
        return nil
    }
    
    func getJoinSource() -> Int {
        if qr_groupPublickKey?.isEmpty == false {
            return 1
        }
        if recommended_groupPublickKey?.isEmpty == false {
            return 2
        }
        if miniLinkGroupId?.isEmpty == false {
            return 3
        }
        return 0
    }
    func getGroupPrivatekey() -> Data? {
        guard let prikey = self.msg?.decodeGroupPrivateKey(),
            prikey.count == 32 else {
                return nil
        }
        return prikey
    }
    
    //MARK:-
    func toSubmitVc() {
        guard let response = self.groupInfo else {
                return
        }
        let pubkey = response.group_id
        let nickname = CPAccountHelper.loginUser()?.accountName ?? ""
        let source = getJoinSource()
        let inviter = getInviterHexPubkey()
        let name = response.name
        
        if let vc = R.loadSB(name: "GroupJoinApproveSubmitVC", iden: "GroupJoinApproveSubmitVC") as? GroupJoinApproveSubmitVC {
            vc.groupPrikey = getGroupPrivatekey()
            vc.pubkey = pubkey
            vc.name = name
            vc.notice = response.notice["content"] as? String ?? ""
            
            vc.nickname = nickname
            vc.source = source
            vc.inviter = inviter
            
            Router.pushViewController(vc: vc)
        }
    }
    
    func showFailJoinAlert() {
        guard let failV = R.loadNib(name: "UploadResultAlert") as? UploadResultAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        failV.imageView?.image = UIImage(named: "backup_result_fail")
        failV.msgLabel?.text = "Group_Join_ecc_tip".localized()
        failV.okButton?.setTitle("OK".localized(), for: .normal)
        Router.showAlert(view: failV)
        failV.okBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Request
    func requestInfo() {
        self.showLoading()
        DispatchQueue.global().async {
            
            let groupPrikey = self.msg?.decodeGroupPrivateKey() ?? Data()
            let calPubkey = OC_Chat_Plugin_Bridge.hexPublicKey(fromPrivatekey: groupPrikey)
            var pubkey = calPubkey
            
            if pubkey.count != 130 {
                let groupPubkey = self.msg?.group_pub_key ?? Data()
                let groupHexPubkey =  groupPubkey.toHexString()
                pubkey = groupHexPubkey
            }
            if pubkey.count != 130 {
                let qrHexpubkey = self.qr_groupPublickKey
                pubkey = qrHexpubkey ?? ""
            }
            if pubkey.count != 130 {
                pubkey = self.recommended_groupPublickKey ?? ""
            }
            if pubkey.count != 130 {
                pubkey = self.miniLinkGroupId ?? ""
            }
            
            //error
            if pubkey.count != 130 {
                DispatchQueue.main.async {
                    self.dismissLoading()
                }
                return
            }
            
            CPGroupManagerHelper.requestServerGroupInfo(pubkey) { [weak self] (r, msg, data) in
                self?.dismissLoading()
                if r == true, let info = data {
                    self?.groupInfo = info
                    self?.loadGroupDetailInfo()
                }
            }
        }
        
    }
    
    func loadGroupDetailInfo() {
        smallRemark?.text = groupInfo?.name.getSmallRemark()
        let color = groupInfo?.group_id.randomColor() ?? RelateDefaultColor
        smallRemark?.backgroundColor = UIColor(hexString: color)
        
        remarkL?.text = groupInfo?.name
        
        if let count =  groupInfo?.member_count  {
            memberCountL?.text = "\(count) \("people".localized())"
        }
    }
}
