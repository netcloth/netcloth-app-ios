







import UIKit

class BackupTipView: UIView {
    @IBOutlet weak var titleL: UILabel?
    @IBOutlet weak var accountBackupBtn: UIButton?
    @IBOutlet weak var contactBackupBtn: UIButton?
    @IBOutlet weak var backupLaterBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    
    
    func showStatus(showAccount:Bool,showContact:Bool) {
        guard showAccount == true ||
            showContact == true else {
                self.isHidden = true
                return
        }
        self.isHidden = false
        
        let showAll = showAccount && showContact
        if showAll {
            allShow()
        } else {
            if showAccount {
                showOnlyAccount()
            } else if showContact {
                showOnlyContact()
            }
        }
    }
    
    
    
    @IBAction func toAccBackup(_ sender: Any) {
        if let vc = R.loadSB(name: "Export", iden: "BackupContainerVC") as? BackupContainerVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    @IBAction func toContactBackup(_ sender: Any) {
        if let vc = R.loadSB(name: "ContactBackup", iden: "ContactBackupStartVC") as? ContactBackupStartVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    @IBAction func toBackupLater(_ sender: Any) {
        self.removeFromSuperview()
        UserSettings.setObject("1", forKey: BackupKey.backupLater.rawValue)
    }
    
    
    
    
    private func configUI() {
        accountBackupBtn?.setTitle("Account Backup".localized(), for: .normal)
        contactBackupBtn?.setTitle("Contacts Backup".localized(), for: .normal)
        backupLaterBtn?.setTitle("Backup Later".localized(), for: .normal)
    }
    
    private func allShow() {
        titleL?.text = "acc_con_all_tip".localized()
        accountBackupBtn?.isHidden = false
        contactBackupBtn?.isHidden = false
        backupLaterBtn?.isHidden = false
    }
    private func showOnlyAccount() {
        titleL?.text = "acc_only_tip".localized()
        accountBackupBtn?.isHidden = false
        contactBackupBtn?.isHidden = true
        backupLaterBtn?.isHidden = false
    }
    private func showOnlyContact() {
        titleL?.text = "con_only_tip".localized()
        accountBackupBtn?.isHidden = true
        contactBackupBtn?.isHidden = false
        backupLaterBtn?.isHidden = false
    }
}

enum BackupKey: String {
    case accountBackup 
    case contactBackup
    case backupLater
    
    case lastLoginDay
}

class BackupTipViewHelper {
    
    static func checkCanShow() -> (showAccount:Bool,showContact:Bool)
    {
        if CPAccountHelper.isLogin() == false {
            return (false, false)
        }
        let uid = Int(CPAccountHelper.loginUser()?.userId ?? 0)
        let lastDay = UserSettings.object(forKey: BackupKey.lastLoginDay.rawValue) as? String
        let now = NSDate().string(withFormat: "yyyy-MM-dd")
        if lastDay == now  {
            if let isLater = UserSettings.object(forKey: BackupKey.backupLater.rawValue) as? String , isLater == "1" {
                return (false, false)
            }
            return _checkCanShow()
        }
        else {
            UserSettings.setObject(now, forKey: BackupKey.lastLoginDay.rawValue)
            UserSettings.deleteKey(BackupKey.backupLater.rawValue, ofUser: uid)
            return _checkCanShow()
        }
    }
    
    private static func _checkCanShow() -> (showAccount:Bool,showContact:Bool)
    {
        var show_acc = true
        if let account = UserSettings.object(forKey: BackupKey.accountBackup.rawValue) as? String , account == "1" {
            show_acc = false
        }
        var show_con = true
        if let contact = UserSettings.object(forKey: BackupKey.contactBackup.rawValue) as? String , contact == "1" {
            show_con = false
        }
        return  (show_acc, show_con)
    }
}
