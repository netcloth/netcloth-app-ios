







import UIKit
class AbstractListVC: BaseViewController,
UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    let disbag = DisposeBag()
    var models: [Any]? = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestData()
    }
    
    
    func requestData() {
        fatalError("must overwrite")
    }
    
    func onTap(row: IndexPath, model: Any?) {
        fatalError("must overwrite")
    }
    
    func cellFor(row: IndexPath) -> UITableViewCell {
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "cell", for: row) as! ContactCell
        return cell
    }
    
    
    func fillData(_ datas: [Any]?) {
        self.models = datas
        self.tableView?.reloadData()
    }
    
    func configUI() {
        
        self.tableView?.adjustHeader()
        self.tableView?.adjustFooter()
        
        self.tableView?.adjustOffset()
        self.tableView?.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    func configEvent() {
        
    }
}

extension AbstractListVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.cellFor(row: indexPath)
        let model = self.models?[indexPath.row]
        
        cell.reloadData(data: model as Any)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.models?[indexPath.row]
        self.onTap(row: indexPath, model: model)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
