







import UIKit

class NCCommonUseTableVC: BaseTableViewController {
    
    @IBOutlet weak var recordL: UILabel?

    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            
        }
        super.viewDidLoad()
        self.tableView.adjustFooter()
    }
}
