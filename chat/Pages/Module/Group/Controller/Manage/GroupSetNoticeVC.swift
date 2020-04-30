







import UIKit

class GroupSetNoticeVC: BaseViewController {
    
    let inEditable: PublishSubject<Bool> = PublishSubject<Bool>()
        
    
    var disbag = DisposeBag()
    
    var cancelBtn: UIBarButtonItem?
    var editBtn: UIBarButtonItem?
    
    var sureBtn: UIBarButtonItem?
    var doneButton: UIButton? 
    
    @IBOutlet weak var headContainer: UIView? 
    @IBOutlet weak var smallRemarkL: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    @IBOutlet weak var timeL: UILabel?
    
    @IBOutlet weak var inputTF: AutoHeightTextView?
    @IBOutlet weak var maskView: UIView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        fillData()
    }
    
    func fillData() {
        if let name = self.roomService?.chatContact?.value.decodeNotice() {
            inputTF?.text = name
        }
    }
    
    func configUI() {
        
        let cancel = "Cancel".localized()
        cancelBtn = UIBarButtonItem(title: cancel, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        cancelBtn?.tintColor = UIColor(hexString: Color.black)
        
        editBtn = UIBarButtonItem(title: "Edit".localized(), style: .plain, target: nil, action: nil)
        editBtn?.tintColor = UIColor(hexString: Color.blue)
        
        
        let btn = UIButton(type: .custom)
        btn.setTitle("Done".localized(), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.backgroundColor = UIColor(hexString: Color.blue)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.layer.cornerRadius = 4
        btn.size.height = 32
        doneButton = btn
        
        sureBtn = UIBarButtonItem(customView: btn)
        
        self.handleHeadChange()
    }
    
    func configEvent() {
        
        cancelBtn?.rx.tap.subscribe({ [weak self] (event) in
            self?.inEditable.onNext(false)
            }).disposed(by: disbag)
        
        editBtn?.rx.tap.subscribe({ [weak self] (event) in
            self?.inEditable.onNext(true)
        }).disposed(by: disbag)
        
        doneButton?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onTapDone()
        }).disposed(by: disbag)
        
        self.inEditable.subscribe { [weak self] (e) in
            if e.element == true {
                self?.showInEdit()
            } else {
                self?.showFirstCanEdit()
            }
        }.disposed(by: disbag)
        
        
        inputTF?.rx.text.skip(1).subscribe { [weak self] (event: Event<String?>) in
            self?.inputTF?.limitLength(by: nil, maxLength: Config.Group.Max_Notice_Len)
            self?.doneButton?.alpha = 1
            self?.doneButton?.isEnabled = true
        }.disposed(by: disbag)
                
        
        self.roomService?.isMeGroupMaster.subscribe(onNext: { [weak self] (isMaster) in
            if isMaster {
                self?.showFirstCanEdit()
            } else {
                self?.onlyQuery()
            }
        }).disposed(by: disbag)
        
        self.roomService?.chatContact?.observable.subscribe({ [weak self] (e) in
            self?.handleHeadChange()
            }).disposed(by: disbag)
        
    }
    
    
    
    func handleHeadChange() {
        let contact = self.roomService?.chatContact?.value
        self.headContainer?.isHidden = contact?.decodeNotice()?.isEmpty ?? true
        
        let publisher = contact?.notice_publisher ?? ""
        let sessionId = contact?.sessionId ?? 0
        let modified_time = contact?.notice_modified_time ?? 0
        
        
        let date = NSDate(timeIntervalSince1970: modified_time)
        let dateStr = date.string(withFormat: "yyyy.MM.dd HH:mm")
        timeL?.text = dateStr
        
        CPGroupManagerHelper.getOneGroupMember(publisher, inSession: Int(sessionId)) {(r, msg, member) in
            self.smallRemarkL?.text = member.nickName.getSmallRemark()
            let color = member.hexPubkey.randomColor()
            self.smallRemarkL?.backgroundColor = UIColor(hexString: color)
            self.remarkL?.text = member.nickName
        }
    }
    
    func showFirstCanEdit() {
        self.navigationItem.hidesBackButton = false
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = self.editBtn
        self.inputTF?.isUserInteractionEnabled = false
    }
    
    func showInEdit() {
        self.navigationItem.leftBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem = self.sureBtn
        self.navigationItem.hidesBackButton = true
        self.inputTF?.isUserInteractionEnabled = true
        
        self.doneButton?.alpha = 0.6
        self.doneButton?.isEnabled = false
    }
    
    func onlyQuery() {
        self.navigationItem.hidesBackButton = false
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.inputTF?.isUserInteractionEnabled = false
        self.inputTF?.placeHolder?.isHidden = true
    }
    
    
    func onTapDone() {
        let r = self.checkInputAvalid()
        if r.result == false {
            Toast.show(msg: r.msg , position: .center)
        }
        else {
            let notice = (self.inputTF?.text)!
            guard let pubkey = self.roomService?.chatContact?.value.publicKey,
                let prikey = self.roomService?.chatContact?.value.decodePrivateKey()
                else {
                return
            }
            
            _ = self.showPostAlert().subscribe(onNext: { [weak self] (r) in
                
                let modified_time = NSDate().timeIntervalSince1970
                let publisher = CPAccountHelper.loginUser()?.publicKey ?? ""
                
                self?.roomService?.chatContact?.change(commit: { (contact) in
                    contact.setSourceNotice(notice)
                    contact.notice_modified_time = modified_time
                    contact.notice_publisher = publisher
                })
                
                let hexenc = self?.roomService?.chatContact?.value.notice_encrypt_content ?? ""
                
                
                self?.showLoading()
                CPGroupChatHelper.sendGroupUpdateNotice(hexenc, groupPrivateKey: prikey) { [weak self] (response) in
                    self?.dismissLoading()
                    let json = JSON(response)
                    if json["code"].int == ChatErrorCode.OK.rawValue {
                        CPGroupManagerHelper.updateGroupNotice(hexenc,
                                                               modifyTime: modified_time,
                                                               publisher: publisher,
                                                               byGroupPubkey: pubkey,
                                                               callback: nil)
                        Router.dismissVC()
                    } else {
                        Toast.show(msg: "System error".localized())
                    }
                }
            })
        }
    }
    
    func showPostAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                
                alert.titleLabel?.isHidden = true
                alert.msgLabel?.text = "Group_Notice_Change_Title".localized()
                alert.msgLabel?.textColor = UIColor(hexString: Color.black)
                
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Post".localized(), for: .normal)
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onNext(())
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }
    
    
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        guard Config.Group.checkNotice(inputTF?.text) else {
            return (false,"Invalid Data".localized())
        }
        return (true, "valid data".localized())
    }
    
}
