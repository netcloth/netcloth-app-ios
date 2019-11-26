







import UIKit
import PromiseKit

class AccountSafeVC:  BaseTableViewController {
    
    @IBOutlet var pwdcell: UITableViewCell?
    @IBOutlet var backupcell: UITableViewCell?
    @IBOutlet var backupContact: UITableViewCell?
    @IBOutlet var restoreContact: UITableViewCell?
    var xBtn: UIButton?
    
    @IBOutlet var pwdLabel: UILabel?
    @IBOutlet var backupLabel: UILabel?
    @IBOutlet var contactBackUp: UILabel?
    @IBOutlet var contactRestore: UILabel?
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {

        }
        super.viewDidLoad()
        self.tableView.adjustFooter()
        fixConfigUI()
        configUI()
        configEvent()
    }
    
    func fixConfigUI() {
        pwdLabel?.text = "Change Password".localized()
        backupLabel?.text = "Account Backup".localized()
        contactBackUp?.text = "Contacts Backup".localized()
        contactRestore?.text = "Restore Contacts".localized()
    }
    
    func configUI() {
        let btn = UIButton(type: .custom)
        self.view.addSubview(btn)
        xBtn = btn
        btn.setTitle("Delete the Account".localized(), for: .normal)
        btn.backgroundColor = UIColor(hexString: "#F4375E")
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        
        btn.snp.makeConstraints { (maker) in
            maker.left.equalTo(12)
            maker.width.equalTo(YYScreenSize().width - 24)
            maker.height.equalTo(44)
            if #available(iOS 11.0, *) {
                maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            } else {

                maker.bottom.equalTo(self.view).offset(-26)
            }
        }
        let color = UIColor(hexString: "#F4375E")
        btn.setShadow(color: color!, offset: CGSize(width: 0, height: 10), radius: 20, opacity: 0.2)

    }
    
    
    func configEvent() {
        self.xBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.deleteAccount()
            }).disposed(by: disbag)
    }
    
    func deleteAccount() {
        guard let user = CPAccountHelper.loginUser() else {
            return
        }
        LoginVC.firstDel(user).then {(res) -> Promise<String>  in
            return LoginVC.reDel(user)
        }.done { (data) in

            MeVC._logout(false)
            CPAccountHelper.deleteUser(Int(user.userId)) { [weak self] (r, msg) in
                if r {

                    UserDefaults.standard.set(nil, forKey: Config.Account.Last_Login_Name)
                    MeVC._postNotify()
                } else {
                    Toast.show(msg: "System error".localized())
                }
            }
        }.catch { error in
            print(error)
        }
    }
    

    func toChangePwd() {
        guard let alert = R.loadNib(name: "ChagePwdTipsAlert") as? ChagePwdTipsAlert  else {
            Toast.show(msg: "System error".localized())
            return
        }
        alert.okBlock = {
            if let vc = R.loadSB(name: "ChangePwd", iden: "ChangePwdController") as? ChangePwdController {
                Router.pushViewController(vc: vc)
            }
        }
        
        Router.showAlert(view: alert)
    }
    
    func toBackupAccount() {
        if let vc = R.loadSB(name: "Export", iden: "BackupContainerVC") as? BackupContainerVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    func toBackupContact() {
        if let vc = R.loadSB(name: "ContactBackup", iden: "ContactBackupStartVC") as? ContactBackupStartVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    func toRestoreContact() { 
        if let vc = R.loadSB(name: "RestoreContact", iden: "RestoreContactStartVC") as? RestoreContactStartVC {
            Router.pushViewController(vc: vc)
        }
    }
}

extension AccountSafeVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let secell = tableView.cellForRow(at: indexPath)
        if secell == self.pwdcell {
            toChangePwd()
        }
        else if secell == self.backupcell {
            toBackupAccount()
        }
        else if secell == self.backupContact {
            toBackupContact()
        }
        else if secell == self.restoreContact {
            toRestoreContact()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let color = UIColor(hexString: "#F5F7FA")
        if let hv = view as? UITableViewHeaderFooterView {
            hv.contentView.backgroundColor = color
        } else {
            view.backgroundColor = color
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return CGFloat.leastNonzeroMagnitude
    }
}
