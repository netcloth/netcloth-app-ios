







import UIKit


class WalletCategoryVC: AbstractListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    func fetchData() {
        let list = NCUserCenter.shared?.walletDataStore.value.list
        self.fillData(list)
        
        DispatchQueue.main.async {
            let canScroll = self.tableView?.contentSize.height ?? 0 > self.tableView?.size.height ?? 0
            self.tableView?.isScrollEnabled = canScroll
        }
    }
    
    
    override func requestData() {
        
    }
    
    override func onTap(row: IndexPath, model: Any?) {
        
        guard row.row != NCUserCenter.shared?.walletDataStore.value.curSection else {
            return
        }
        
        NCUserCenter.shared?.walletDataStore.change(commit: { (ds) in
            ds.curSection = row.row
        })
        fetchData()
    }
    
    override func cellFor(row: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "cell", for: row) as! WalletCategoryCell
        
        let cursecion = NCUserCenter.shared?.walletDataStore.value.curSection
        if row.row == cursecion {
            cell.selectBg()
        } else {
            cell.deselectBg()
        }
        
        return cell
    }
    
}
