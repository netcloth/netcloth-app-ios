  
  
  
  
  
  
  

import UIKit

class GroupSetNameVC: BaseViewController {
    
    @IBOutlet weak var sureBtn: UIButton?
    @IBOutlet weak var inputTF: UITextField?
    @IBOutlet weak var maskView: UIView?
    
    var disbag = DisposeBag()
    
      
    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
              
        }
        
        super.viewDidLoad()
        configUI()
        configEvent()
        fillData()
    }
    
    func fillData() {
        
        if let name = self.roomService?.chatContact?.value.remark {
            inputTF?.text = name
            inputTF?.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func configUI() {
        self.sureBtn?.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        
          
        inputTF?.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.maskView?.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_fill)
            } else {
                self?.maskView?.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_empty)
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
            let old = self.roomService?.chatContact?.value.remark
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
            CPGroupChatHelper.sendGroupUpdateName(name, groupPrivateKey: prikey) { [weak self] (response) in
                self?.dismissLoading()
                let json = JSON(response)
                if json["code"].int == ChatErrorCode.OK.rawValue {
                    self?.roomService?.chatContact?.change(commit: { (contact) in
                        contact.remark = name
                    })
                    CPGroupManagerHelper.updateGroupName(name, byGroupPubkey: pubkey
                        , callback: nil)
                    Router.dismissVC()
                } else {
                    Toast.show(msg: "System error".localized())
                }
            }

            
        }
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        guard Config.Group.checkName(inputTF?.text) else {
            return (false,"Group_invalid_name".localized())
        }
        return (true, "valid data".localized())
    }
    
}
