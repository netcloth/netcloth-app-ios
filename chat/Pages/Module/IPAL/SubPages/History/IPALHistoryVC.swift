//
//  IPALHistoryVC.swift
//  chat
//
//  Created by Grand on 2019/11/9.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class IPALHistoryVC: BaseViewController,
UITableViewDataSource, UITableViewDelegate {
    
    // 1 chat  3application
    var pageTag: IPAListVC.PageTag?
    
    @IBOutlet weak var tableView: UITableView?
    var list:[CPChainClaim]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        requestData()
    }
    
    func configUI() {
        self.tableView?.adjustFooter()
        self.tableView?.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    func requestData() {
        if pageTag ==  IPAListVC.PageTag.C_IPAL {
            CPAssetHelper.getCipalHistoryLimited {[weak self] (array) in
                self?.list = array
                self?.tableView?.reloadData()
            }
        }
        else if pageTag == IPAListVC.PageTag.A_IPAL {
            CPAssetHelper.getAIPALHistoryLimited {[weak self] (array) in
                self?.list = array
                self?.tableView?.reloadData()
            }
        }
    }
}

extension IPALHistoryVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        
        let data = list?[safe: indexPath.row]
        cell.reloadData(data: data)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard self.pageTag == .C_IPAL else {
            return
        }
        
        //to detail
        if let data = list?[safe: indexPath.row] {
            if let vc = R.loadSB(name: "IPALResult", iden: "IPALHistoryDetailVC") as? IPALHistoryDetailVC {
                vc.queryHistoryNode = data
                Router.pushViewController(vc: vc)
            }
        }
    }
}
