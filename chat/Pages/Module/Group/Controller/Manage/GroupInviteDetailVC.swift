  
  
  
  
  
  
  

import UIKit


  
class GroupInviteDetailVC: BaseViewController {
    
    @IBOutlet weak var smallRemark: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    @IBOutlet weak var memberCountL: UILabel?
    @IBOutlet weak var joinBtn: UIButton?
    
    var msg: CPMessage?    
    var qr_groupPublickKey: String?   
    
    let disbag = DisposeBag()
    
    private var groupInfo: CPGroupInfoResp?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configEvent()
        requestInfo()
    }
    
      
    func configEvent() {
        self.joinBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onJoinTap()
        }).disposed(by: disbag)
    }
    
      
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
                  
                let notice = self?.groupInfo?.notice["content"] as? String ?? ""
                CPGroupManagerHelper.joinGroup(byGroupName: name, groupPrivateKey: groupPrikey, groupNotice: notice, callback: { (r, msg, contact) in
                      
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
                  
                self?.showFailJoinAlert()
            } else {
                  
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
        return 0
    }
    func getGroupPrivatekey() -> Data? {
        guard let prikey = self.msg?.decodeGroupPrivateKey(),
            prikey.count == 32 else {
                return nil
        }
        return prikey
    }
    
      
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
        remarkL?.text = groupInfo?.name
        
        if let count =  groupInfo?.member_count  {
            memberCountL?.text = "\(count) \("people".localized())"
        }
    }
}
