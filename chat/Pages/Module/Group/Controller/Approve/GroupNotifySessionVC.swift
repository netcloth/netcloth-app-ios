//
//  GroupNotifyPreviewVC.swift
//  chat
//
//  Created by Grand on 2019/12/26.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class GroupNotifySessionVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?
    
    var dataArray: [CPGroupNotifySession]? {
        didSet {
            var count = 0
            if let array = self.dataArray {
                for item in array {
                    count += item.unreadCount
                }
                allUnreadCount = count
            }
        }
    }
    
    var allUnreadCount: Int = 0 {
        didSet {
            let count = self.allUnreadCount
            if count == 0 {
                self.title = "Group Notices".localized()
            } else {
                self.title = "\("Group Notices".localized())(\(count))"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        allUnreadCount = 0
        configEvent()
        loadData()
    }
    
    func configEvent() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NoticeNameKey.groupNotifyReadStatusChange.noticeName, object: nil)
    }
    
    @objc func loadData() {
        self.showLoading()
        CPGroupManagerHelper.getDistinctGroupNotifySessionCallback {[weak self] (r, msg, array) in
            self?.dismissLoading()
            self?.dataArray = array
            self?.tableView?.reloadData()
        }
    }
    
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath)
        let data = dataArray?[safe: indexPath.row]
        cell.reloadData(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let data = dataArray?[safe: indexPath.row] {
            if let vc = R.loadSB(name: "GroupDistinctSenderVC", iden: "GroupDistinctSenderVC") as? GroupDistinctSenderVC {
                vc.groupContact = data.relateContact
                Router.pushViewController(vc: vc)
            }
        }
    }
}
