







import Foundation

class AboutVC: BaseViewController {
    
    @IBOutlet weak var versionL: UILabel?
    @IBOutlet weak var officialWebL: UIControl?
    @IBOutlet weak var githubL: UIControl?
    @IBOutlet weak var blogL: UIControl?
    @IBOutlet weak var supportUs: UIControl?

    
    @IBOutlet weak var officialText: UILabel?
    @IBOutlet weak var githubText: UILabel?
    @IBOutlet weak var blogText: UILabel?
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    func configUI() {
        versionL?.text = "V\(Device.getAppVersion())"
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
    }
    
    func toSupportUs() {
        CPContactHelper.getAllContacts { [weak self]  (contacts) in
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.publicKey == support_account_pubkey {
                    ct.remark = "NetCloth Support".localized()
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
