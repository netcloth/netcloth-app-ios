







import Foundation

class AboutVC: BaseViewController {
    
    @IBOutlet weak var versionL: UILabel?
    @IBOutlet weak var officialWebL: UIControl?
    @IBOutlet weak var githubL: UIControl?
    @IBOutlet weak var blogL: UIControl?
    @IBOutlet weak var supportUs: UIControl?
    @IBOutlet weak var UserCenter: UIControl?
    
    @IBOutlet weak var logoIcon: UIView?

    
    @IBOutlet weak var officialText: UILabel?
    @IBOutlet weak var githubText: UILabel?
    @IBOutlet weak var blogText: UILabel?
    @IBOutlet weak var userCenterText: UILabel?
    
    @IBOutlet weak var serviceBtn: UIButton?
    @IBOutlet weak var privacyBtn: UIButton?

    
    let disbag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
        
    func configUI() {
        versionL?.text = "\(AppBundle.getAppVersion())"
        
        
        let tap = UITapGestureRecognizer { [weak self] _ in
            self?.addOrRemoveDebug()
        }
        tap.numberOfTapsRequired = 8
        logoIcon?.isUserInteractionEnabled = true;
        logoIcon?.addGestureRecognizer(tap)
        
        if GlobalStatusStore.shared.curAssist == nil {
            self.supportUs?.isHidden = true
        }
    }
    
    func addOrRemoveDebug() {
        if let obj = UserDefaults.standard.object(forKey: "CusDeb") as? String, obj == "cd" {
            UserDefaults.standard.removeObject(forKey: "CusDeb")
            Toast.show(msg: "Release...".localized())
        }
        else {
            UserDefaults.standard.set("cd", forKey: "CusDeb")
            Toast.show(msg: "Debug...".localized())
        }
    }
    
    func configEvent() {
        officialWebL?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let url = URL(string: (self?.officialText?.text)!)!
            UIApplication.shared.open(url)
        }).disposed(by: disbag)
        
        githubL?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let url = URL(string: (self?.githubText?.text)!)!
            UIApplication.shared.open(url)
        }).disposed(by: disbag)
        
        blogL?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let url = URL(string: (self?.blogText?.text)!)!
            UIApplication.shared.open(url)
        }).disposed(by: disbag)
        
        
        supportUs?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.toSupportUs()
        }).disposed(by: disbag)
        
        UserCenter?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let url = URL(string: (self?.userCenterText?.text)!)!
            UIApplication.shared.open(url)
        }).disposed(by: disbag)
        
        serviceBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let url = URL(string: Config.NetOfficial.ServiceUrl) {
                UIApplication.shared.openURL(url)
            }
        }).disposed(by: disbag)
        
        privacyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let url = URL(string: Config.NetOfficial.PrivacyUrl) {
                UIApplication.shared.openURL(url)
            }
        }).disposed(by: disbag)

    }
    
    func toSupportUs() {
        CPContactHelper.getAllContacts { [weak self]  (contacts) in
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.publicKey == GlobalStatusStore.shared.curAssist?.pub_key {
                    return true
                }
                return false
            }
            
            if let ct = filter[safe: 0] {
                if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC {
                    vc.sessionId = Int(ct.sessionId)
                    vc.toPublicKey = ct.publicKey
                    vc.remark = ct.remark
                    Router.pushViewController(vc: vc)
                }
            }
        }
    }
}
