







import UIKit

class WalletManageNameVC: BaseViewController {
    
    @IBOutlet weak var changeNameBtn: UIButton?
    
    let disbag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    fileprivate func configUI() {
        guard let wallet = self.vcInitData as? WalletInterface else {
            return
        }
        changeNameBtn?.setTitle(wallet.name, for: .normal)
    }
    
    fileprivate func configEvent() {
        changeNameBtn?.addTarget(self, action: #selector(onChangeName), for: UIControl.Event.touchUpInside)
    }
    
    
    @objc fileprivate func onChangeName() {
        
        if let alert = R.loadNib(name: "NormalInputAlert") as? NormalInputAlert {
            
            alert.titleLabel?.text = "Change Wallet Name".localized()
            
            alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.inputTextField?.placeholder = "No more than 20 characters".localized()
            
            alert.checkPreview = { [weak self, weak alert] in
                
                guard let name = alert?.inputTextField?.text,
                    name.isEmpty == false,
                    name.count >= 1,
                    name.count <= 20 else {
                        Toast.show(msg: "No more than 20 characters".localized())
                    return false
                }
                return true
            }
            
            alert.okBlock = { [weak self, weak alert] in
                guard let name = alert?.inputTextField?.text else {
                    return
                }
                self?.onRealChangeName(name)
            }
        }
    }
    
    fileprivate func onRealChangeName(_ toname: String) {
        guard var wallet = self.vcInitData as? WalletInterface else {
            return
        }
        configUI()
        
        NCUserCenter.shared?.walletDataStore.observable.onNext(())
    }
}
