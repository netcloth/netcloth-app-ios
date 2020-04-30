







import UIKit

class GroupCreateResponseVC: BaseViewController {
    
    @IBOutlet weak var noteLabel: PaddingLabel?
    @IBOutlet weak var backupBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
    }
    
    deinit {
        GroupRoomService.createdGroup = nil
    }
    
    func configUI() {
        noteLabel?.preferredMaxLayoutWidth = YYScreenSize().width - 12*2
        noteLabel?.edgeInsets = UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)

        backupBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20, opacity: 0.3)
    }
    
    @IBAction func onTapBackup() {
        if let vc = R.loadSB(name: "ContactBackup", iden: "ContactBackupStartVC") as? ContactBackupStartVC {
            Router.pushViewController(vc: vc)
        }
    }
}
