







import Foundation

class MsgAlertSettingVC: BaseTableViewController {
    
    @IBOutlet weak var shakeSwitch: UISwitch!
    @IBOutlet weak var bellSwitch: UISwitch!
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {

        }
        super.viewDidLoad()
        self.tableView.adjustFooter()
        configUI()
        refreshCells()
        configEvent()
    }
    
    func configUI() {
        self.shakeSwitch.onTintColor = UIColor(hexString: "#3D7EFF")
        self.shakeSwitch.tintColor = UIColor(hexString: "#E1E4E9")
        self.bellSwitch.onTintColor = UIColor(hexString: "#3D7EFF")
        self.bellSwitch.tintColor = UIColor(hexString: "#E1E4E9")
    }
    
    func configEvent() {
        shakeSwitch.rx.value.subscribe(onNext: { (isOn) in
            Config.Settings.shakeble = isOn
        }).disposed(by: disbag)
        
        bellSwitch.rx.value.subscribe(onNext: { (isOn) in
            Config.Settings.bellable = isOn
        }).disposed(by: disbag)
    }
 
    func refreshCells() {
        self.shakeSwitch.isOn = Config.Settings.shakeble
        self.bellSwitch.isOn = Config.Settings.bellable
    }
}
