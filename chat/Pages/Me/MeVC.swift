







import UIKit
import FCFileManager
import MessageUI

class MeVC: BaseViewController
    ,MFMailComposeViewControllerDelegate
{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageV: UIImageView!
    @IBOutlet weak var avatarImgVTop: NSLayoutConstraint!
    
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var addressContainer: UIView!
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var copyKeyBtn: UIButton!
    
    @IBOutlet weak var showqrBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var safeControl: UIControl!
    @IBOutlet weak var settingControl: UIControl!
    @IBOutlet weak var aboutControl: UIControl!
    
    @IBOutlet weak var editControl: UIControl?
    
    @IBOutlet weak var hubImage: UIImageView?
    @IBOutlet weak var hubLabel: UILabel?
    
    
    let disposeBag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
        configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameL.text = (CPAccountHelper.loginUser()?.accountName ?? "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleConnectChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var top : CGFloat?
        if #available(iOS 11.0, *) {
            top = self.view.safeAreaInsets.top + 25
        } else {

            top = 45
        }
        
        if self.avatarImgVTop.constant != top {
            self.avatarImgVTop.constant = top!
        }
    }
    

    func configEvent() {
        

        editControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "Rename", iden: "RenameVC")
            Router.pushViewController(vc: vc)
        })
            .disposed(by: disposeBag)
        
        copyKeyBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let pubkey = CPAccountHelper.loginUser()?.publicKey {
                UIPasteboard.general.string = pubkey
                Toast.show(msg: NSLocalizedString("Copy Share", comment: ""))
            }
        })
            .disposed(by: disposeBag)
        
        showqrBtn.rx.tap.subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "QrCode", iden: "QrCodeVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        
        logoutBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.onLogout()
        }).disposed(by: disposeBag)
        
        

        safeControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "AccountSafe", iden: "AccountSafeVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        

        settingControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "Setting", iden: "SettingVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        

        aboutControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            let vc = R.loadSB(name: "About", iden: "AboutVC")
            Router.pushViewController(vc: vc)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: NSNotification.Name.serviceConnectStatusChange, object: nil)
    }
    
    func configUI() -> Void {
        
        self.scrollView.adjustOffset()
        self.logoutBtn.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
        
        self.tabBarItem.setStyle(imgName: "我的-未选中",
                                 selectedName: "我的-选中",
                                 textColor: UIColor(hexString: "#BFC2CC"),
                                 selectedColor: UIColor(hexString: "#3D7EFF"))
        
        let pbkey = CPAccountHelper.loginUser()?.publicKey
        self.publicKeyLabel.text = pbkey
        

        let tap = UITapGestureRecognizer { [weak self] _ in
            self?.sendDebugDBInfo()
        }
        tap.numberOfTapsRequired = 5
        avatarImageV.isUserInteractionEnabled = true;
        avatarImageV.addGestureRecognizer(tap)
        
    }
    

    func onLogout() {
        Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Log Out", comment: ""), cancelAction: nil, okAction: {
            MeVC._logout()
        })
    }
    
    static func _logout(_ post:Bool = true) {
        CPAccountHelper.logout()
        if post {
            _postNotify()
        }
    }
    
    static func _postNotify() {
        NotificationCenter.post(name: .loginStateChange)
    }
    
    @objc func handleConnectChange() {
        let isClaimOk = IPALManager.shared.store.currentCIpal?.isClaimOk == 1
        let isClaimFail = IPALManager.shared.store.currentCIpal?.isClaimOk == 2
        
        if CPAccountHelper.isConnected() && isClaimOk {
            hubImage?.image = UIImage(named: "connect_ok")
            hubLabel?.text = "connect_ok".localized()
        } else {
            if CPAccountHelper.isNetworkOk() && !isClaimFail {
                hubImage?.image = UIImage(named: "connect_ing")
                hubLabel?.text = "connect_ing".localized()
            } else {
                hubImage?.image = UIImage(named: "connect_fail")
                hubLabel?.text = "connect_fail".localized()
            }
        }
    }
    

    func sendDebugDBInfo() {
        guard MFMailComposeViewController.canSendMail() else {
            Toast.show(msg: "please check your email")
            return
        }
        Toast.showLoading()
        DispatchQueue.global().async {
            
            let logsData = CPChatLog.zipLogs()
            guard let logd = logsData else {
                DispatchQueue.main.async {
                    Toast.dismissLoading()
                }
                return;
            }
            
            DispatchQueue.main.async {
                Toast.dismissLoading()
                let mf = MFMailComposeViewController()
                mf.setToRecipients(["log@netcloth.org"])
                

                let name = String(CPAccountHelper.loginUser()?.publicKey.prefix(16) ?? "logs")
                mf.addAttachmentData(logd as Data, mimeType: "zip", fileName: "\(name).zip")
                
                mf.mailComposeDelegate = self
                Router.present(vc: mf, animate: true)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        if result == .sent {
            Toast.show(msg: "send")
        }
    }
}
