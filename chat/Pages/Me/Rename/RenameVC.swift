  
  
  
  
  
  
  

import UIKit

class RenameVC: BaseViewController {
    
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
        if let name = CPAccountHelper.loginUser()?.accountName {
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
        }.disposed(by: disbag)
        
          
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            
            let r = self?.checkInputAvalid()
            if r?.result == false {
                Toast.show(msg: r?.msg ?? "", position: .center)
            }
            else {
                let name = (self?.inputTF?.text)!
                CPAccountHelper.changeLoginUserName(name) { (r, msg) in
                    if r == false {
                        Toast.show(msg: msg)
                    } else {
                        UserDefaults.standard.set(name, forKey: Config.Account.Last_Login_Name)
                        Router.dismissVC()
                    }
                }
            }
            
        }).disposed(by: disbag)
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        guard Config.Account.checkAccount(inputTF?.text) else {
            return (false,"Register_invalid_account".localized())
        }
        return (true, "valid data".localized())
    }
    
}
