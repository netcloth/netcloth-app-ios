







import UIKit
import WMPageController


class ExportDetailVC: WMPageController {

    deinit {
        print("\(type(of: self))")
    }
    
    var keyStore: String?
    var privateKey: String?
    
    var index: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = false
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {

        }
        self.configUI()
        if index != 0 {
            self.selectIndex = Int32(index)
        }
        showAlert()
    }
    
    func showAlert() -> Void {
        guard let alert = R.loadNib(name: "NoCaptureAlert") as? NoCaptureAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        if index == 1 {
            alert.msgLabel?.text = "Export_Alert_Prikey".localized()
        }
        
        Router.showAlert(view: alert)
    }
    
    func configUI() {
        self.menuView?.layoutMode = .center
        self.menuItemWidth = YYScreenSize().width / 2
        self.menuView?.backgroundColor = UIColor(hexString: "#F7F8FA")
        
        self.titleColorSelected = UIColor(hexString: "#3D7EFF")!
        self.titleColorNormal = UIColor(hexString: "#909399")!
        
        self.reloadData()
    }
    

    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 2
    }
    
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        if index == 0 {
            let vc = R.loadSB(name: "Export", iden: "BackUpKSDetailVC")
            vc.vcInitData = self.keyStore as AnyObject?
            return vc
        }
        else {
            let vc = R.loadSB(name: "Export", iden: "BackUpPrivateKeyVC")
            vc.vcInitData = self.privateKey as AnyObject?
            return vc
        }
    }
    
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        if index == 0 {
            return "Keystore"
        }
        else {
            return "Private Key".localized()
        }
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        let top = self.navigationController?.navigationBar.frame.maxY ?? 0
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: 48)
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = (self.navigationController?.navigationBar.frame.maxY ?? 0 ) + 48
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: YYScreenSize().height - top)
    }
}



class BackUpKSDetailVC: BaseViewController {
    
    @IBOutlet weak var copyBtn: UIButton?
    @IBOutlet weak var nextBtn: UIButton?
    @IBOutlet weak var keystoreLabel: PaddingLabel?
    
    var disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: "#F7F8FA")
        self.keystoreLabel?.edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.keystoreLabel?.preferredMaxLayoutWidth = YYScreenSize().width - 27*2
        if let ks = self.vcInitData as? String {
            self.keystoreLabel?.text = ks
        }
        
        self.copyBtn?.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
         self.nextBtn?.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        self.copyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let ks = self?.vcInitData as? String {
                UIPasteboard.general.string = ks
                Toast.show(msg: "Successful copy".localized())
            }
        }).disposed(by: disbag)
        
        self.nextBtn?.rx.tap.subscribe(onNext: { [weak self] in

            if let vc = R.loadSB(name: "Export", iden: "ExportKeyStoreVerifyVC") as? ExportKeyStoreVerifyVC {
                Router.pushViewController(vc: vc)
            }
        }).disposed(by: disbag)
    }
}


class BackUpPrivateKeyVC: BaseViewController {
    
    @IBOutlet weak var nextBtn: UIButton?
    @IBOutlet weak var privateKeyLabel: PaddingLabel?
    
    var disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.view?.backgroundColor = UIColor(hexString: "#F7F8FA")
        self.privateKeyLabel?.edgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.privateKeyLabel?.preferredMaxLayoutWidth = YYScreenSize().width - 27*2
        if let ks = self.vcInitData as? String {
            self.privateKeyLabel?.text = ks
        }
        
        self.nextBtn?.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
        #if DEBUG || Adhoc
        let tap = UITapGestureRecognizer(actionBlock: { [weak self] ges in
            if let ks = self?.vcInitData as? String {
                UIPasteboard.general.string = ks
                Toast.show(msg: "Successful copy".localized())
            }
        })
        self.privateKeyLabel?.addGestureRecognizer(tap)
        self.privateKeyLabel?.isUserInteractionEnabled = true
        #endif
    }
    
    func configEvent() {
        
        self.nextBtn?.rx.tap.subscribe(onNext: { [weak self] in

            if let vc = R.loadSB(name: "Export", iden: "ExportPrivateKeyVerifyVC") as? ExportPrivateKeyVerifyVC {
                vc.originPrivateKey = self?.privateKeyLabel?.text
                Router.pushViewController(vc: vc)
            }
            
        }).disposed(by: disbag)
    }
    
}
