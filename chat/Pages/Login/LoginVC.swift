







import UIKit
import IQKeyboardManagerSwift
import swift_cli
import PromiseKit

class LoginVC: BaseViewController  {
    
    @IBOutlet weak var importControl: UIControl!
    
    @IBOutlet weak var accountTF: UITextField!
    @IBOutlet weak var accountMask: UIView!
    
    @IBOutlet weak var switchIcon: UIImageView!
    @IBOutlet weak var switchBtn: UIButton!

    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var imageVEye: UIImageView!
    @IBOutlet weak var pwdMask: UIView!
    @IBOutlet weak var switchEye: UIButton!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginBtnTop: NSLayoutConstraint!
    
    @IBOutlet weak var accountTable: UITableView!
    @IBOutlet weak var tableMask: UIView!
    @IBOutlet weak var accountTableHeight: NSLayoutConstraint!
    
    var selectedIndex = 0
    
    var sourceNames:[User]?
    let accountNames: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var isSelectedAccount: Bool = false {
        didSet {
            self.accountTable.isHidden = !isSelectedAccount
            self.tableMask.isHidden = self.accountTable.isHidden
        }
    }
    
    var isShowPwd:Bool = false {
        didSet {
            self.pwdTF.isSecureTextEntry = !self.isShowPwd
            self.imageVEye.image = self.isShowPwd ? UIImage(named: "open_eye") : UIImage(named: "close")
        }
    }
    
    var lastLoginUser: String? {
        get {
            return UserDefaults.standard.object(forKey: Config.Account.Last_Login_Name) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Config.Account.Last_Login_Name)
        }
    }
    
    @IBOutlet weak var envBtn: UIButton?
    
    let disbag = DisposeBag()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        self.isHideNavBar = true
        configUI()
        configEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fillWithLastUser()
        reloadTable()
    }
    

    func reloadTable() {
        CPAccountHelper.allUserListCallback({(result) in
            self.sourceNames = result
            self.switchIcon.isHidden = self.sourceNames?.isEmpty ?? true
            self.switchBtn.isUserInteractionEnabled =  !(self.switchIcon.isHidden)
            let h = Int(self.accountTable.rowHeight)
            let c = self.sourceNames?.count ?? 1
            self.accountTableHeight.constant = CGFloat(h * c)
            self.accountNames.accept(self.sourceNames ?? [])
            
            if let t = self.sourceNames {
                for (index, item) in t.enumerated() {
                    if item.accountName == self.lastLoginUser {
                        self.selectedIndex = index
                    }
                    print("索引：\(index)  元素：\(item)")
                }
            }
            
        })
    }
    
    func fillWithLastUser() {
        self.accountTF.text = self.lastLoginUser
    }
    
    
    func configUI() {
        self.accountTable.tableFooterView = UIView()
        self.tableMask.setShadow(color: UIColor(hexString: "#BFC2CC")!, offset: CGSize(width: 0, height: 0), radius: 15, opacity: 0.18)
        
        if YYScreenSize().height <= 500 {
            loginBtnTop.constant = 40
        }
        
        self.loginBtn.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    var tmp = 0
    func configEvent()  {
        
        accountNames.bind(to: accountTable.rx.items(cellIdentifier: "cellID",cellType: loginCell.self)){ [weak self] ( row, model, cell) in
            cell.nameL?.text = model.accountName
            cell.selectionStyle  = .none
            

            cell.xbtn?.rx.tap.subscribe(onNext: { [weak self] in
                self?.deleteAccount(model)
            }).disposed(by: cell.disposeBag)
            
            if row == ((self?.sourceNames?.count ?? 0) - 1) {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: YYScreenSize().width)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            }
            
        }.disposed(by: disbag)
        
        accountTable.rx.itemSelected.subscribe { [weak self](indexpath) in
            self?.isSelectedAccount = false
            self?.accountTF.text = self?.sourceNames?[indexpath.element?.row ?? 0].accountName
            self?.accountTF.sendActions(for: .valueChanged)
            self?.selectedIndex = indexpath.element?.row ?? 0
        }.disposed(by: disbag)
        
        switchBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isSelectedAccount = !(self?.isSelectedAccount ?? false)
        }).disposed(by: disbag)
        
        switchEye.rx.tap.subscribe(onNext: { [weak self] in
           self?.isShowPwd = !((self?.isShowPwd)!)
        }).disposed(by: disbag);
        
        accountTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.accountMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_fill)
            } else {
                self?.accountMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_empty)
            }
        }.disposed(by: disbag)
        
        pwdTF.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.pwdMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_fill)
            } else {
                self?.pwdMask.backgroundColor = UIColor(hexString: Config.Color.mask_bottom_empty)
            }
            }.disposed(by: disbag)
        
        
        self.loginBtn.rx.tap.subscribe(onNext: { [weak self] in
            
            if self?.tmp != 0 {
                return
            }
            self?.tmp = 1
            
            let r = self?.checkInputAvalid()
            if r?.result == false {
                let et = NSLocalizedString("login_invalid_data", comment: "")
                Toast.show(msg: et, position: .center)
                self?.tmp = 0
            }
            else {
                let index = self?.selectedIndex ?? 0
                let uid = self?.sourceNames?[safe: index]?.userId ?? 0
                
                Toast.showLoading()
                CPAccountHelper.login(withUid: Int(uid), password: (self?.pwdTF.text)!, callback: { (success, msg) in
                    Toast.dismissLoading()
                    self?.tmp = 0
                    
                    if success == false {
                        let t = msg ?? "login_wrong_pwd".localized()
                        Toast.show(msg: t, position: .center)
                    } else {
                        self?.lastLoginUser = self?.accountTF.text
                        NotificationCenter.post(name: .loginStateChange)
                    }
                })
            }
            
        }).disposed(by: disbag)
        

        self.importControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            
            if let vc = R.loadSB(name: "Import", iden: "ImportAccountContainerVC") as? ImportAccountContainerVC {
                Router.pushViewController(vc: vc)
            }
            
        }).disposed(by: disbag)
        
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        guard Config.Account.checkAccount(accountTF.text)  else {
            return (false,"请输入有效用户名")
        }
        
        guard Config.Account.checkLoginPwd(pwdTF.text)  else {
            return (false,"请输入正确密码");
        }
        return (true, "有效数据")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
        self.isSelectedAccount = false
    }
    

    static func firstDel(_ user: User) -> Promise<String> {
        let alert =  Promise<String> { (resolver) in
            
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {

                alert.titleLabel?.text = "login_delete_title".localized()
                
                let msg = "login_delete_message".localized().replacingOccurrences(of: "#account#", with: user.accountName)
                alert.msgLabel?.text = msg
                
                alert.cancelButton?.setTitle("Back".localized(), for: .normal)
                alert.okButton?.setTitle("confirm_delete".localized(), for: .normal)
                
                alert.okBlock = {
                    resolver.fulfill("ok")
                }
                alert.cancelBlock = {
                    let error = NSError(domain: "login", code: 0, userInfo: nil)
                    resolver.reject(error)
                }
                
                Router.showAlert(view: alert)
            }
        }
        return alert
    }
    
    static func reDel(_ user: User) -> Promise<String> {
        let re_alert =  Promise<String> { (resolver) in
                   
                   if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {

                       alert.titleLabel?.text = "login_delete_title".localized()
                       
                       let msg = "login_delete_re_message".localized().replacingOccurrences(of: "#account#", with: user.accountName)
                       alert.msgLabel?.text = msg
                       
                       alert.cancelButton?.setTitle("Back".localized(), for: .normal)
                       alert.okButton?.setTitle("confirm_delete".localized(), for: .normal)
                       
                       alert.okBlock = {
                           resolver.fulfill("ok")
                       }
                       alert.cancelBlock = {
                           let error = NSError(domain: "login", code: 0, userInfo: nil)
                           resolver.reject(error)
                       }
                       
                       Router.showAlert(view: alert)
                   }
               }
        return re_alert;
    }
    
    func deleteAccount(_ user: User) {
        
        LoginVC.firstDel(user).then {(res) -> Promise<String>  in
            return LoginVC.reDel(user)
        }.done { (data) in

            CPAccountHelper.deleteUser(Int(user.userId)) { [weak self] (r, msg) in
                if r {
                    if user.accountName == self?.lastLoginUser {
                        self?.lastLoginUser = nil
                    }
                    self?.reloadTable()
                    self?.fillWithLastUser()
                } else {
                    Toast.show(msg: "System error".localized())
                }
            }
        }.catch { error in
            print(error)
        }
    }
}


class loginCell : UITableViewCell {
    @IBOutlet var nameL: UILabel?
    @IBOutlet var xbtn: UIButton?
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
