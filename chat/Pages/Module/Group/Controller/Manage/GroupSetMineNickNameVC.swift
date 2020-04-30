







import UIKit

class GroupSetMineNickNameVC: BaseViewController {
    
    var sureBtn: UIButton?
    @IBOutlet weak var inputTF: UITextField?
    
    var disbag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        fillData()
    }
    
    func fillData() {
        
        if let name = self.roomService?.myGroupAlias.value {
            inputTF?.text = name
            inputTF?.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func configUI() {
        
        
        let btn = UIButton(type: .custom)
        btn.setTitle("Done".localized(), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.backgroundColor = UIColor(hexString: Color.blue)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.layer.cornerRadius = 4
        btn.size.height = 32
        sureBtn = btn
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    func configEvent() {
        
        
        inputTF?.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            } else {
            }
            self?.inputTF?.limitLength(by: nil, maxLength: Config.Group.Max_Name_Len)
        }.disposed(by: disbag)
        
        
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onTapDone()
        }).disposed(by: disbag)
    }
    
    
    func onTapDone() {
        let r = self.checkInputAvalid()
        if r.result == false {
            Toast.show(msg: r.msg , position: .center)
        }
        else {
            let name = (self.inputTF?.text)!
            let old = self.roomService?.myGroupAlias.value
            if name == old {
                Router.dismissVC()
                return
            }
            
            guard let pubkey = self.roomService?.chatContact?.value.publicKey,
                let prikey = self.roomService?.chatContact?.value.decodePrivateKey()
                else {
                return
            }
            
            self.showLoading()
            CPGroupChatHelper.sendGroupUpdateNickName(name, groupPrivateKey: prikey) { [weak self] (response) in
                self?.dismissLoading()
                let json = JSON(response)
                if json["code"].int == ChatErrorCode.OK.rawValue {
                    self?.roomService?.myGroupAlias.accept(name)
                    CPGroupManagerHelper.updateGroupMyAlias(name, byGroupPubkey: pubkey, callback: nil)
                    Router.dismissVC()
                    
                } else {
                    Toast.show(msg: "System error".localized())
                }
            }
            
        }
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        guard Config.Group.checkName(inputTF?.text) else {
            return (false,"Group_invalid_nickname".localized())
        }
        return (true, "valid data".localized())
    }
    
}
