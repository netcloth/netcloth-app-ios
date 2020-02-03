  
  
  
  
  
  
  

import Foundation

class SettingVC: BaseTableViewController {
    
    @IBOutlet var languageLabel: UILabel?
    @IBOutlet var msgNoticeLabel: UILabel?
    @IBOutlet var cipalLabel: UILabel?
    @IBOutlet var commomLabel: UILabel?
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
              
        }
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: Config.Color.app_bg_color)
        self.tableView.adjustFooter()
        fixConfigUI()
    }
    
    func fixConfigUI() {
        languageLabel?.text = "Language".localized()
        msgNoticeLabel?.text = "Notifications".localized()
        cipalLabel?.text = "C-IPAL Settings".localized()
        commomLabel?.text = "General".localized()
    }
}

extension SettingVC {
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
           let color = UIColor(hexString: "#F7F8FA")
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
