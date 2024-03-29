







import UIKit
import IQKeyboardManagerSwift

class TokenPwdInputVC: BaseViewController {
    
    @IBOutlet weak var pwdTF: UITextField?
    @IBOutlet weak var errorTipL: UILabel?
    
    @IBOutlet weak var nextBtn: UIButton?
    
    let disbag = DisposeBag()
    
    deinit {
        IQKeyboardManager.shared.disabledToolbarClasses.removeLast()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configEvent()
        
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses.append(type(of: self))
    }
    
    func configEvent() {
        pwdTF?.rx.value.skip(1).subscribe(onNext: { [weak self] (text) in
            self?.errorTipL?.isHidden = true
        }).disposed(by: disbag)
    }
    
    @IBAction func onNext() {
        
        if checkPwdValid() == false {
            self.errorTipL?.isHidden = false
            return
        }
        
        self.bubbleView?.confirmObserver.confirmPwdOK?()
    }
    
    fileprivate func checkPwdValid() -> Bool {
        let pwd = pwdTF?.text
        
        if CPAccountHelper.checkLoginUserPwd(pwd) == false {
            return false
        }
        return true
    }
}
