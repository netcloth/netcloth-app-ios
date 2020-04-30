







import UIKit

class GroupApproveDetailVC: BaseViewController {
    
    @IBOutlet weak var confirmControl: UIButton?
    @IBOutlet weak var refuseControl: UIButton?
    
    @IBOutlet weak var smallL: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    @IBOutlet weak var inviterBy: UILabel?
    
    @IBOutlet weak var reasonL: UILabel?
    
    var latestNotice: CPGroupNotify?
    var groupContact: CPContact?

    
    let disbag = DisposeBag()
    
    
    
    deinit {
        let noticeId = self.latestNotice?.noticeId ?? 0
        var notice = self.latestNotice
        CPGroupManagerHelper.updateGroupNotifyToRead(inNoticeId: noticeId) { (r, msg) in
            if r {
                notice?.status = DMNotifyStatus.read
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        guard let notice = self.latestNotice,
            let joinMsg = notice.decodeJoinRequest else {
                return
        }
        remarkL?.text = joinMsg.nickName
        smallL?.text = joinMsg.nickName.getSmallRemark()
        
        let color = notice.senderPublicKey.randomColor()
        smallL?.backgroundColor = UIColor(hexString: color)
        
        
        refreshInviter()
        refreshReason()
        refreshStatus()
        self.reasonL?.preferredMaxLayoutWidth = YYScreenSize().width - (30 + 24)
    }
    
    func configEvent() {
        
        confirmControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] (e) in
            self?.filfulled()
        }).disposed(by: disbag)
        
        refuseControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] (e) in
            self?.rejected()
        }).disposed(by: disbag)
        
        if self.latestNotice?.inviterNickName == nil,
            self.latestNotice?.decodeJoinRequest?.source == 0
            {
            _ = decodeInviter().subscribe(onNext: { [weak self] (e) in
                self?.refreshInviter()
            })
        }
    }
    
    private func decodeInviter() -> Observable<Bool> {
        return Observable.create { [weak self] (observer) -> Disposable in
            
            let memberPubkey = self?.latestNotice?.decodeJoinRequest?.inviterPubKey.toHexString() ?? ""
            let sid = self?.groupContact?.sessionId ?? 0
            CPGroupManagerHelper.getOneGroupMember(memberPubkey, inSession: Int(sid)) { (r, msg, groupMember) in
                var nickname = groupMember.nickName
                if nickname.isEmpty {
                    nickname = memberPubkey.getPubkeyAbbreviate()
                }
                
                self?.latestNotice?.inviterNickName = nickname
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    
    fileprivate func refreshInviter() {
        
        
        if self.latestNotice?.decodeJoinRequest?.source == 1 {
            self.inviterBy?.text = "Group_Request_From_QR".localized()
            self.inviterBy?.textColor = UIColor(hexString: "#606266")
        }
        else if self.latestNotice?.decodeJoinRequest?.source == 2 {
            self.inviterBy?.text = "Group_Request_From_Recommend".localized()
            self.inviterBy?.textColor = UIColor(hexString: "#606266")
        }
        else if self.latestNotice?.decodeJoinRequest?.source == 3 {
            self.inviterBy?.text = "Group_request_from_miniLink".localized()
            self.inviterBy?.textColor = UIColor(hexString: "#606266")
        }
        else if let inviter = self.latestNotice?.inviterNickName {
            var att1 = NSMutableAttributedString(string: "Notify_detail_inviter".localized())
            att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: "#606266")!], range: att1.rangeOfAll())
            
            var att2 = NSMutableAttributedString(string: "\(inviter)")
            att2.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: att2.rangeOfAll())
            
            let range1 = (att1.string as? NSString)?.range(of: "#mark#")
            if let r1 = range1, r1.location != NSNotFound {
                att1.replaceCharacters(in: r1, with: att2)
            }
            self.inviterBy?.attributedText = att1
        }
    }
    
    fileprivate func refreshReason() {
        let memberPubkey = self.latestNotice?.senderPublicKey ?? ""
        let sid = self.groupContact?.sessionId ?? 0
        CPGroupManagerHelper.getGroupNotify(inSession: sid, ofRequestUser: memberPubkey) { [weak self] (r, msg, notice) in
            
            var array = [Observable<Bool>]()
            for item in notice {
                array.append(InnerHelper.decode(notice: item))
            }
            
            var reason = ""
            Observable.zip(array).observeOn(MainScheduler.instance)
                .subscribe(onNext: { (array) in
                    for item in notice {
                        reason += "\(item.decodeRequestReason() ?? "") \n"
                    }
                    self?.reasonL?.text = reason
                })
        }
    }
    
    fileprivate func refreshStatus() {
        let canNext = self.latestNotice?.status == DMNotifyStatus.unread ||  self.latestNotice?.status == DMNotifyStatus.read
        self.confirmControl?.isEnabled = canNext
        self.refuseControl?.isEnabled = canNext
    }
    
    
    
    fileprivate func filfulled() {
        guard let group = self.groupContact,
            let notice = self.latestNotice,
            let joinMsg = notice.join_msg else {
                return
        }
        let groupPrikey = group.decodePrivateKey()
        let groupName = group.remark
        showLoading()
        CPGroupChatHelper.sendGroupJoinApproved(joinMsg, groupPrivateKey: groupPrikey, groupName: groupName) { [weak self] (response) in
            self?.dismissLoading()
            let json = JSON(response)
            if let code = json["code"].int ,
                (code == ChatErrorCode.OK.rawValue || code == ChatErrorCode.memberDuplicate.rawValue) {
                self?.latestNotice?.status = DMNotifyStatus.fulfilled
                
                let memberPubkey = self?.latestNotice?.senderPublicKey ?? ""
                let sid = self?.groupContact?.sessionId ?? 0
                CPGroupManagerHelper.updateGroupNotify(inSession: sid, ofRequestUser: memberPubkey, to: DMNotifyStatus.fulfilled, callback: nil)
                self?.refreshStatus()
            } else {
                Toast.show(msg: "System error".localized())
            }
        }
    }
    
    fileprivate func rejected() {
        guard let group = self.groupContact,
            let notice = self.latestNotice,
            let joinMsg = notice.join_msg else {
                return
        }
        self.latestNotice?.status = DMNotifyStatus.reject
        let memberPubkey = self.latestNotice?.senderPublicKey ?? ""
        let sid = self.groupContact?.sessionId ?? 0
        CPGroupManagerHelper.updateGroupNotify(inSession: sid, ofRequestUser: memberPubkey, to: DMNotifyStatus.reject, callback: nil)
        
        self.refreshStatus()
    }
    
}
