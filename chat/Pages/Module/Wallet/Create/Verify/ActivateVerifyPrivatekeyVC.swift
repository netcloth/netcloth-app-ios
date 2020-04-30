







import Foundation

class ActivateVerifyPrivatekeyVC: BaseViewController {
    
    @IBOutlet weak var privateKeyInput: AutoHeightTextView?
    @IBOutlet weak var verifyBtn: UIButton?
    
    var originPrivateKey: String?
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: Color.gray_f7)
        self.verifyBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        self.verifyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let pk = self?.privateKeyInput?.text,
                let opk = self?.originPrivateKey,
                pk.isEmpty == false
            {
                if pk == opk {
                    self?.showValidAlert()
                } else {
                    self?.showInvalidAlert()
                }
            }
            else {
                Toast.show(msg: "WalletManager.Error.invalidData".localized())
            }
        }).disposed(by: disbag)
    }
    
    func showValidAlert() {
        UserSettings.setObject("1", forKey: Config.Account.wallet_exist_tag)
        NCUserCenter.shared?.walletManage.value.inCreatingWallet = false
        Router.dismissVC(animate: false, toRoot: true)
        
        if let rootVC = Router.rootVC as? UINavigationController,
            let baseTabVC = rootVC.topViewController as? GrandTabBarVC,
            let meVc = baseTabVC.selectedViewController as? MeVC
        {
            meVc.toWallet()
        }
        
        if let v = R.loadNib(name: "MayImageAlertView") as? MayImageAlertView {
            v.imageV?.image = UIImage(named: "create_success")
            v.cancelButton?.isHidden = true
            v.msgLabel?.isHidden = true
            v.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            v.titleLabel?.text = "Activate_succ_tip".localized()
            v.okButton?.setTitle("OK_Yeah".localized(), for: .normal)
            Router.showAlert(view: v)
        }
    }
    
    func showInvalidAlert() {
        
        if let v = R.loadNib(name: "MayImageAlertView") as? MayImageAlertView {
            v.imageV?.image = UIImage(named: "create_fail")
            v.cancelButton?.isHidden = true
            v.titleLabel?.text = "Activate_fail_tip".localized()
            v.msgLabel?.text = "Activate_fail_prikey".localized()
            v.okButton?.setTitle("Try Again".localized(), for: .normal)
            Router.showAlert(view: v)
        }
    }

}
