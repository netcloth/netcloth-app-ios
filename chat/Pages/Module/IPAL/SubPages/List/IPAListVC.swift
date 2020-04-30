//
//  IPAListVC.swift
//  chat
//
//  Created by Grand on 2019/11/5.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

class IPAListVC:
    BaseViewController,
    UITableViewDataSource,
UITableViewDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating {
    
    enum PageTag: Int {
        case C_IPAL = 1
        case A_IPAL = 3
    }
 
    var fromSource: PageTag =  .C_IPAL {
        didSet {
            let fs = self.fromSource
            switch fs {
            case .C_IPAL:
                self.title = "Communication Server".localized()
            case .A_IPAL:
                self.title = "Application Server".localized()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var headerView: IPAListHeaderView?
    @IBOutlet weak var searchContainerView: UIView?
    var searchViewController: UISearchController?
    
    var list:[IPALNode]?
    
    let disbag = DisposeBag()
    //MARK:- LifeCycle
    deinit {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        requestAllCIpals()
        self.headerView?.vcViewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView?.reloadData()
    }
    
    func configUI() {
        self.tableView?.adjustOffset()
        self.tableView?.adjustFooter()
        
        
        //search
        let result = R.loadSB(name: "IPALList", iden: "IPALSearchResultVC") as? IPALSearchResultVC
        result?.selectedNodeCallBack = {[weak self] node in
            self?.selectConnectNode(node)
        }
        result?.pageTag = self.fromSource
        
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
            if self?.fromSource == .C_IPAL {
                self?.reloadHeader(node: event.element ?? nil)
            }
        }.disposed(by: disbag)
        
        IPALManager.shared.store.rx.observe(IPALNode.self, "curAIPALNode").subscribe {[weak self] (event) in
            if self?.fromSource == .A_IPAL {
                self?.reloadHeader(node: event.element ?? nil)
                self?.reloadTableView()
            }
        }.disposed(by: disbag)
        
        self.headerView?.historyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.toHistory()
        }).disposed(by: disbag)
    }
    
    fileprivate func reloadHeader(node: IPALNode?) {
        self.headerView?.reloadData(node)
    }
    
    //MARK:- header
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

    
    
    //MARK:- Action
    func toHistory() {
        if let vc = R.loadSB(name: "IPALResult", iden: "IPALHistoryVC") as? IPALHistoryVC {
            vc.pageTag = self.fromSource
            Router.pushViewController(vc: vc)
        }
    }
    
    // Connect Node
    func selectConnectNode(_ node: IPALNode?) {
        if self.fromSource == .C_IPAL {
            _cipal_selectNode(node)
        }
        else if self.fromSource == .A_IPAL {
            _aipal_selectNode(node)
        }
    }
    
    fileprivate func _cipal_selectNode(_ node: IPALNode?) {
        guard let n = node else {
            return
        }
        
        if IPALManager.shared.store.currentCIpal == nil {
            if let server = node {
                self.tryToBind_Cipal_Service(server)
            }
        }
        else if IPALManager.shared.store.currentCIpal?.operator_address != node?.operator_address {
            self.popTips().done { (result) in
                if result == "ok" {
                    //pop to callback vc
                    if let server = node {
                        self.tryToBind_Cipal_Service(server)
                    }
                }
            }
        }
    }
    
    fileprivate func _aipal_selectNode(_ node: IPALNode?) {
        guard let n = node else {
            return
        }
        
        if IPALManager.shared.store.curAIPALNode == nil {
            if let server = node {
                self.tryToBind_AIpal_Service(server)
            }
        }
        else if IPALManager.shared.store.curAIPALNode?.operator_address != node?.operator_address {
            self.popAIPALTips().done { (result) in
                if result == "ok" {
                    //pop to callback vc
                    if let server = node {
                        self.tryToBind_AIpal_Service(server)
                    }
                }
            }
        }
    }
    
    
    //MARK:- Fetch
    func requestAllCIpals() {
        self.showLoading()
        ChainService.requestAllChatServer().done { (list:[IPALNode]) in
            var chatEnters: [IPALNode] = []
            if self.fromSource == .C_IPAL {
                chatEnters = InnerHelper.filterCIPALs(list: list)
            } else if self.fromSource == .A_IPAL {
                chatEnters = InnerHelper.filterAIPALs(list: list)
            }
            self.list = chatEnters
            
            if self.fromSource == .C_IPAL &&
                self.shouldShowGuide() &&
                chatEnters.count > 0 {
                self.dismissLoading()
                
                
                ///Note
                var officeNode: IPALNode? = nil
                var targetIndex = 0
                for index in 0 ..< chatEnters.count {
                    if let item = chatEnters[index] as? IPALNode,
                        item.operator_address == Config.officialNodeAddress  {
                        officeNode = item
                        targetIndex = index
                    }
                }
                if officeNode != nil && targetIndex != 0 {
                    chatEnters.swapAt(0, targetIndex)
                    self.list = chatEnters
                }
                
                self.requestPings(showLoading: false, notOrder: true)
                self.handleShowGuide()
            }
            else {
                self.requestPings()
            }
            self.reloadTableView()
        }
        .catch { (err) in
            
        }
    }
    
    
    
    //MARK:- Ping
    let sessionT = URLSession(configuration: URLSessionConfiguration.default)
    let signal = DispatchSemaphore(value: 3)
    let queue =  OS_dispatch_queue_concurrent(label: "ping.queue")
    var total = 0
    func requestPings(showLoading: Bool = false, notOrder: Bool = false) {
        if showLoading {
            self.showLoading()
        }
        guard let seq = self.list,
            seq.count > 0 else {
                self.dismissLoading()
                return
        }
        total = 0
        for item in seq {
            if let endPoint = item.cIpalEnd(), let address = endPoint.endpoint {
                //v1/ping
                let str = address + "/v1/ping"
                let url = URL(string: str)
                if url == nil {
                    continue
                }
                total += 1
                
                let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5)
                self.queue.async {
                    self.signal.wait()
                    let starttime = Date().timeIntervalSince1970 * 1000 //ms
                    let starttime2 = Date().timeIntervalSince1970 * 1000 //ms
                    let task = self.sessionT.dataTask(with: request, completionHandler: { (data, response, error) in
                        let endtime = Date().timeIntervalSince1970 * 1000 //ms
                        self.signal.signal()
                        let diff = fabs(endtime - starttime)
                        if error == nil {
                            item.ping = Int(diff)
                        } else {
                            item.ping = NSNotFound
                        }
                        DispatchQueue.main.async {
                            self.exeafterPing(notOrder: notOrder)
                        }
                    })
                    task.resume()
                }
                
            }
        }
    }
    
    func exeafterPing(notOrder: Bool) {
        total -= 1
        
        if total % 2 == 0 {
            if notOrder == false {
                self.list?.sort(by: { (l, r) -> Bool in
                    if l.ping == 0 {
                        if r.ping == 0 {
                            return true
                        }
                        return false
                    }
                    return l.ping < r.ping
                })
            }
            //multi times
            self.reloadTableView()
        }
        
        /// 全部ping 结束，本轮结束开始下一轮
        if total == 0 {
            DispatchQueue.main.async {
                self.dismissLoading()
                self.tableView?.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: { [weak self] in
                self?.requestPings(notOrder: notOrder)
            })
        }
    }
    
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    func orderListAndRefresh() {
        self.list?.sort(by: { (l, r) -> Bool in
            if l.ping == 0 {
                if r.ping == 0 {
                    return true
                }
                return false
            }
            return l.ping < r.ping
        })
        reloadTableView()
    }
    
    
    
    //MARK:-
    func tryToBind_Cipal_Service(_ node: IPALNode) {
        IPALManager.shared.onStep2_BindNode(node)
    }
    
    func tryToBind_AIpal_Service(_ node: IPALNode) {
        
        ///Note: close proxy before
        NCUserCenter.shared?.proxy.change(commit: { (store) in
            store.openProxy = false
            store.host = ""
            store.port = 0
        })
        
        CPAssetHelper.insertAIPALHistroyMoniker(node.moniker,
                                                server_address: node.operator_address,
                                                endPoint: (node.aIpal()?.endpoint ?? ""),
                                                callback: nil)
        IPALManager.shared.store.curAIPALNode = node
    }

    
    func popTips() -> Promise<String> {
        let alert =  Promise<String> { (resolver) in
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                //config
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
    
    func popAIPALTips() -> Promise<String> {
        let alert =  Promise<String> { (resolver) in
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                //config
                alert.titleLabel?.text = "Tips_Title".localized()
                alert.msgLabel?.text = "Tips_Msg_Switch_AIPAL".localized()
                
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
}

//MARK:-  Guide
extension IPAListVC {
    
    func shouldShowGuide() -> Bool {
        #if DEBUG
        return true
        #endif
        
        if let ng = UserSettings.object(forKey: "NG_IPAL") as? String,
            ng == "NG" {
            return false
        }
        return true
    }
    
    func handleShowGuide() {
        UserSettings.setObject("NG", forKey: "NG_IPAL")
        DispatchQueue.main.async {
            self.showGuide_1()
        }
    }
    
    fileprivate func showGuide_1() {
        let gv = GuideView()
        
        let headframe = self.headerView?.frame ?? CGRect.zero
        let toMaskRect = self.headerView?.superview?.convert(headframe, to: Router.rootWindow!) ?? CGRect.zero
        
        let x: CGFloat = 12
        let y = toMaskRect.maxY + 8
        let w = YYScreenSize().width - 120
        let h = YYScreenSize().height - y - 18
        let tMaskR = CGRect(x: x, y: y, width: w, height: h)
        
        let imgName = Bundle.is_zh_Hans() ? "ipal_guide_zh_1" : "ipal_guide_en_1"
        let image = UIImage(named: imgName)
        
        
        let imgW: CGFloat = image?.size.width ?? 0
        let imgH: CGFloat = image?.size.height ?? 0
        
        let x_1 = min(76, YYScreenSize().width - imgW - 44)
        let imgRect = CGRect(x: x_1, y: y - 20 - imgH , width: imgW, height: imgH)
        gv.addMask(maskRect: tMaskR, cornerRadius: 10, image: image, imageRect: imgRect)
        
        gv.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self,weak gv] in
            gv?.removeFromSuperview()
            self?.showGuide_2()
        }).disposed(by: disbag)
    }
    
    
    fileprivate func showGuide_2() {
        
        let gv = GuideView()
        
        let firstCell = self.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? IPCell
        
        let headframe = firstCell?.evaluationL?.frame ?? CGRect.zero
        let toMaskRect = firstCell?.evaluationL?.superview?.convert(headframe, to: Router.rootWindow!) ?? CGRect.zero
        
        let w = toMaskRect.width + 30 * 2
        let h = toMaskRect.height + 20 * 2
        
        let x: CGFloat = toMaskRect.minX - 30
        let y = toMaskRect.minY - 20
        
        let tMaskR = CGRect(x: x, y: y, width: w, height: h)
        
        let imgName = Bundle.is_zh_Hans() ? "ipal_guide_zh_2" : "ipal_guide_en_2"
        let image = UIImage(named: imgName)
        let imgW: CGFloat = image?.size.width ?? 0
        let imgH: CGFloat = image?.size.height ?? 0
        
        let x_1 = min(toMaskRect.minX, YYScreenSize().width - imgW - 44)
        
        let imgRect = CGRect(x: x_1, y: tMaskR.maxY + 20 , width: imgW, height: imgH)
        gv.addMask(maskRect: tMaskR, cornerRadius: 10, image: image, imageRect: imgRect)
        
        
        gv.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self, weak gv] in
            gv?.removeFromSuperview()
            self?.showGuide_3()
        }).disposed(by: disbag)
    }
    
    
    fileprivate func showGuide_3() {
        
        let gv = GuideView()
        
        let headframe = self.headerView?.frame ?? CGRect.zero
        let toMaskRect = self.headerView?.superview?.convert(headframe, to: Router.rootWindow!) ?? CGRect.zero
        
        let firstCell = self.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? IPCell
        
        let w: CGFloat = (firstCell?.connectBtn?.width ?? 40) + 30 + 12
        let x: CGFloat = YYScreenSize().width - w - 12
        let y = toMaskRect.maxY + 8
        let h = YYScreenSize().height - y - 18
        
        let tMaskR = CGRect(x: x, y: y, width: w, height: h)
        
        let imgName = Bundle.is_zh_Hans() ? "ipal_guide_zh_3" : "ipal_guide_en_3"
        let image = UIImage(named: imgName)
        let imgW: CGFloat = image?.size.width ?? 0
        let imgH: CGFloat = image?.size.height ?? 0
        
        let x_1 = YYScreenSize().width - 46 - imgW
        let imgRect = CGRect(x: x_1, y: y - 5 - imgH , width: imgW, height: imgH)
        gv.addMask(maskRect: tMaskR, cornerRadius: 10, image: image, imageRect: imgRect)
        
        gv.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self, weak gv] in
            gv?.removeFromSuperview()
            self?.orderListAndRefresh()
        }).disposed(by: disbag)
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
        cell.reloadData(atIndex: indexPath.row + 1, data: data, pageTag: self.fromSource)
        
        //abserver button click
        cell.connectBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.selectConnectNode(data)
        }).disposed(by: cell.disposeBag)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.fromSource == .A_IPAL else {
            return
        }
        let node = self.list?[safe: indexPath.row]
        if node?.operator_address ==
            IPALManager.shared.store.curAIPALNode?.operator_address {
            Router.dismissVC(animate: true, completion: nil, toRoot: true)
            //select ipal
            if let rootVC = Router.rootVC as? UINavigationController,
                let baseTabVC = rootVC.topViewController as? GrandTabBarVC {
                baseTabVC.switchToTab(index: 2)
            }
        }
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
        
        (self.searchViewController?.searchResultsController as? IPALSearchResultVC)?.reloadTable(list: searchResult)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
    }
}
