







import UIKit

class WalletListVC: AbstractListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    override func configUI() {
        super.configUI()
        self.tableView?.backgroundColor = UIColor(hexString: Color.gray_f4)
        if #available(iOS 11.0, *) {
            self.tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.view.safeAreaInsets.bottom, right: 0)
        } else {
            
        }
    }
    
    override func configEvent() {
        super.configEvent()
        NCUserCenter.shared?.walletDataStore.observable.subscribe(onNext: { [weak self] in
            self?.fetchData()
        }).disposed(by: disbag)
    }
    
    func fetchData() {
        let list = NCUserCenter.shared?.walletDataStore.value.listOfCurSection()
        self.fillData(list)
    }
    
    
    override func requestData() {}
    override func onTap(row: IndexPath, model: Any?) {}
        
    override func cellFor(row: IndexPath) -> UITableViewCell {
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "cell", for: row) as! WalletListCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        if let model = self.models?[indexPath.row] as? WalletInterface,
            let vc = R.loadSB(name: "WalletDetailVC", iden: "WalletDetailVC") as? WalletDetailVC {
            vc.vcInitData = model as AnyObject
            Router.pushViewController(vc: vc)
        }
    }
}
