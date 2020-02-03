  
  
  
  
  
  
  

import UIKit
import PromiseKit
import Alamofire

class IPAListVC:
    BaseViewController,
    UITableViewDataSource,
UITableViewDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating{
    
    enum PageTag {
        case C_IPAL
        case A_IPAL
    }
    
    var fromSource: PageTag =  .C_IPAL {
        didSet {
            let fs = self.fromSource
            switch fs {
            case .C_IPAL:
                self.title = "Communication Address".localized()
            case .A_IPAL:
                self.title = "A-IPAL"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var headerView: IPAListHeaderView?
    @IBOutlet weak var searchContainerView: UIView?
    var searchViewController: UISearchController?
    
    var list:[IPALNode]?
    
    let disbag = DisposeBag()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        requestAllCIpals()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView?.reloadData()
    }
    
    func configUI() {
        self.tableView?.adjustOffset()
        self.tableView?.adjustFooter()
        
        
          
        let result = R.loadSB(name: "IPALList", iden: "SearchResultVC") as? SearchResultVC
        result?.selectedNodeCallBack = {[weak self] node in
            self?.selectConnectNode(node)
        }
        
        let searchVC = UISearchController(searchResultsController: result)
        self.searchViewController = searchVC
        searchVC.delegate = self
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = false
        
        self.definesPresentationContext = true

        let searchBar = self.searchViewController!.searchBar
        self.searchContainerView?.addSubview(searchBar)
        searchBar.frame = self.searchContainerView!.bounds
        searchBar.placeholder = "Search".localized()
        
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
  
  
  
        
    }
    
    func configEvent() {
        IPALManager.shared.store.rx.observe(IPALNode.self, "currentCIpal").subscribe {[weak self] (event) in
            if let e = event.element {
                self?.headerView?.reloadData(e)
            } else {
                self?.headerView?.reloadData(nil)
            }
            
        }.disposed(by: disbag)
        
        self.headerView?.historyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.toHistory()
        }).disposed(by: disbag)
    }
    
      
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.calculateHeaderView()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            self.calculateHeaderView()
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.calculateHeaderView()
    }
    
    var fixed:CGFloat = 0.0
    func calculateHeaderView() {
        if fixed == 0 {
            fixed = (self.headerView?.containerV?.frame.minY ?? 0) - 5.0
        }
        let contentOffset = self.tableView?.contentOffset
        var frame =  self.headerView?.frame
        if  contentOffset!.y - fixed > 0 {
            frame?.origin.y = (contentOffset?.y ?? 0) - fixed
            self.headerView?.frame = frame!
        } else {
            frame?.origin.y = 0
            self.headerView?.frame = frame!
        }
        
    }

    
    
      
    func toHistory() {
        if let vc = R.loadSB(name: "IPALResult", iden: "IPALHistoryVC") as? IPALHistoryVC {
            Router.pushViewController(vc: vc)
        }
    }
    
      
    let sessionT = URLSession(configuration: URLSessionConfiguration.default)
    let signal = DispatchSemaphore(value: 3)
    let queue =  OS_dispatch_queue_concurrent(label: "ping.queue")
    
    deinit {
    }
    
    func requestAllCIpals() {
        self.showLoading()
        ChainService.requestAllChatServer().done { (list:[IPALNode]) in
            let chatEnters = list.filter({ (item:IPALNode) -> Bool in
                if let obj = UserDefaults.standard.object(forKey: "CusDeb") as? String, obj == "cd" {
                    if item.cIpalEnd() != nil  {
                        return true
                    }
                }
                else {
                    if item.cIpalEnd() != nil,
                        item.details?.starts(with: "test") == false  {
                        return true
                    }
                }
                return false
            })
            self.list = chatEnters
            self.requestPings()
            self.reloadTableView()
        }
        .catch { (err) in
            
        }
    }
    
    var total = 0
    func requestPings() {
        guard let seq = self.list else {
            return
        }
        total = 0
        for item in seq {
            if let endPoint = item.cIpalEnd(), let address = endPoint.endpoint {
                  
                let str = address + "/v1/ping"
                let url = URL(string: str)
                if url == nil {
                    continue
                }
                total += 1
                
                let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
                self.queue.async {
                    self.signal.wait()
                    let starttime = Date().timeIntervalSince1970 * 1000   
                    let starttime2 = Date().timeIntervalSince1970 * 1000   
                    let task = self.sessionT.dataTask(with: request, completionHandler: { (data, response, error) in
                        let endtime = Date().timeIntervalSince1970 * 1000   
                        self.signal.signal()
                        let diff = fabs(endtime - starttime)
                        if error == nil {
                            item.ping = Int(diff)
                        } else {
                            item.ping = NSNotFound
                        }
                        DispatchQueue.main.async {
                            self.exeafterPing()
                        }
                    })
                    task.resume()
                }
                
            }
        }
    }
    
    func exeafterPing() {
        total -= 1
        if total % 2 == 0 {
            self.list?.sort(by: { (l, r) -> Bool in
                if l.ping == 0 {
                    if r.ping == 0 {
                        return true
                    }
                    return false
                }
                return l.ping < r.ping
            })
              
            self.reloadTableView()
        }
        
        if total == 0 {
            self.recycleReloadTableAfterPings()
        }
    }
    
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func recycleReloadTableAfterPings() {
        DispatchQueue.main.async {
            self.dismissLoading()
            self.tableView?.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: { [weak self] in
            self?.requestPings()
        })
    }
    
      
    func selectConnectNode(_ node: IPALNode?) {
        guard let n = node else {
            return
        }
        
        if IPALManager.shared.store.currentCIpal == nil {
              
            self.popAlert()
            .done { (result) in
                if result == "ok" {
                      
                    if let server = node {
                        self.tryToBindCipalService(server)
                    }
                }
            }
        }
        else if IPALManager.shared.store.currentCIpal?.operator_address != node?.operator_address {
            self.popTips().then({ (result) -> Promise<String> in
                return self.popAlert()
            }).done { (result) in
                if result == "ok" {
                      
                    if let server = node {
                        self.tryToBindCipalService(server)
                    }
                }
            }
        }
    }
    
    func tryToBindCipalService(_ node: IPALNode) {
        IPALManager.shared.onStep2_BindNode(node)
    }
    
    func popTips() -> Promise<String> {
        let alert =  Promise<String> { (resolver) in
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                  
                alert.titleLabel?.text = "Tips_Title".localized()
                alert.msgLabel?.text = "Tips_Msg_Switch".localized()
                
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Confirm".localized(), for: .normal)
                
                alert.okBlock = {
                    resolver.fulfill("ok")
                }
                alert.cancelBlock = {
                    let error = NSError(domain: "ipallist", code: 0, userInfo: nil)
                    resolver.reject(error)
                }
                Router.showAlert(view: alert)
            }
        }
        return alert
    }
    
    
    func popAlert() -> Promise<String>  {
        let _promise = Promise<String> { [weak self] (resolver) in
            
            guard let alert = R.loadNib(name: "ErrorTipsInputAlert") as? ErrorTipsInputAlert  else {
                let error = NSError(domain: "ipal", code: 0, userInfo: nil)
                resolver.reject(error)
                return
            }
            
            alert.titleLabel?.text = "Enter Password".localized()
            alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            alert.checkTipsLabel?.text = "login_wrong_pwd".localized()
            alert.checkTipsLabel?.isHidden = true
            alert.inputTextField?.isSecureTextEntry = true
            Router.showAlert(view: alert)
            
            alert.checkPreview = { [weak alert] in
                let pwd = alert?.inputTextField?.text
                  
                if CPAccountHelper.checkLoginUserPwd(pwd) == false {
                    alert?.checkTipsLabel?.isHidden = false
                    return false
                }
                return true
            }
            
            alert.cancelBlock = {
                let error = NSError(domain: "ipal", code: 0, userInfo: nil)
                resolver.reject(error)
            }
            
            alert.okBlock = {
                resolver.fulfill("ok")
            }
        }
        return _promise
    }

}


extension IPAListVC {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor =  UIColor.clear 
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IPCell", for: indexPath) as! IPCell
        let data = self.list?[safe: indexPath.row]
        cell.reloadData(atIndex: indexPath.row + 1, data: data)
        
          
        cell.connectBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.selectConnectNode(data)
        }).disposed(by: cell.disposeBag)
        
        cell.selectionStyle = .none
        return cell
    }
    
}

extension IPAListVC {
    func updateSearchResults(for searchController: UISearchController) {
        var searchResult:[IPALNode]? = []
        if let text = searchController.searchBar.text {
            searchResult = list?.filter({ (node) -> Bool in
                if node.moniker?.lowercased().contains(text.lowercased()) == true {
                    return true
                }
                return false
            })
            
            searchResult?.sort(by: { (l, r) -> Bool in
                return l.ping < r.ping
            })
            
        } else {
            searchResult = []
        }
        
        (self.searchViewController?.searchResultsController as? SearchResultVC)?.reloadTable(list: searchResult)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
  
    }
    
}


  

  
class IPAListHeaderView: UIView {
    
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tipLabel: UILabel?
    
    @IBOutlet weak var containerV : UIView?
    @IBOutlet weak var bgImageV : UIImageView?
    
    @IBOutlet weak var nameL : UILabel?
    @IBOutlet weak var statusL : UILabel?
    @IBOutlet weak var historyBtn : UIButton?
    
      

    func reloadData(_ data: IPALNode?) {
        nameL?.text = data?.moniker
        handleConnectChange()
    }
    
    @objc func handleConnectChange() {
        let isClaimOk = IPALManager.shared.store.currentCIpal?.isClaimOk == 1
        let isClaimFail = IPALManager.shared.store.currentCIpal?.isClaimOk == 2
        
        if CPAccountHelper.isConnected() && isClaimOk {
            self.statusL?.text = "ipal_connect_ok".localized()
            self.bgImageV?.image = UIImage(named: "ipal_connect_ok_bg")
        } else {
            if CPAccountHelper.isNetworkOk() && !isClaimFail {
                self.statusL?.text = "ipal_connect_ing".localized()
                self.bgImageV?.image = UIImage(named: "ipal_connect_ing_bg")
            } else {
                self.statusL?.text = "ipal_connect_fail".localized()
                self.bgImageV?.image = UIImage(named: "ipal_connect_fail_bg")
            }
        }
    }
    
    deinit {
        print("dealloc \(type(of: self))")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: NSNotification.Name.serviceConnectStatusChange, object: nil)
    }
}

class HeaderContainerView: UIView {
    @IBOutlet weak var header: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil {
            var array = self.header?.allSubViews ?? []
            array = array.filter { (v) -> Bool in
                return v is UIButton
            }
            
            for subview in array {
                let subPoint = subview.convert(point, from: self)
                if subview.bounds.contains(subPoint) {
                    return subview
                }
            }
        }
        return view
    }
}
