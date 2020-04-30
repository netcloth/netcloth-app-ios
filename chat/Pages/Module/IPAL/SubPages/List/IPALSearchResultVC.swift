







import UIKit

class IPALSearchResultVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var pageTag: IPAListVC.PageTag = .C_IPAL
    
    @IBOutlet weak var tableView: UITableView?
    var list:[IPALNode]?
    
    var selectedNodeCallBack : ((IPALNode?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.adjustFooter()
    }
    
    func reloadTable(list: [IPALNode]?) {
        self.list = list
        self.tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IPCell", for: indexPath) as! IPCell
        let data = self.list?[safe: indexPath.row]
        cell.reloadData(atIndex: indexPath.row + 1, data: data, pageTag: self.pageTag)
        
        
        cell.connectBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.selectedNodeCallBack?(data)
        }).disposed(by: cell.disposeBag)
        
        cell.selectionStyle = .none
        return cell
    }
}
