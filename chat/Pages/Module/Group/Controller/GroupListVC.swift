//
//  GroupListVC.swift
//  chat
//
//  Created by Grand on 2019/12/5.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class GroupListVC: AbstractIndexRankVC {
    
    override func configUI() {
        super.configUI()
        self.title = "Group Chat".localized()
    }
    
    var groupCount: Int = 0 {
        didSet {
            let count = self.groupCount
            if count == 0 {
                self.title = "Group Chat".localized()
            } else {
                self.title = "\("Group Chat".localized())(\(count))"
            }
        }
    }
    
    override func requestData() {
        CPContactHelper.getGroupListContacts{ [weak self]  (contacts) in
            self?.groupCount = contacts?.count ?? 0
            self?.fillData(contacts)
        }
    }
    
    fileprivate func toRecommendedGroup() {
        if let vc = R.loadSB(name: "RecommendedGroupListVC", iden: "RecommendedGroupListVC") as? RecommendedGroupListVC {
            vc.recommendGroups = GlobalStatusStore.shared.recommendedGroup
            Router.pushViewController(vc: vc)
        }
    }
    
    override func onTap(row: IndexPath, model: CPContact?) {
        
        #if DEBUG
        if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
            vc.chatContact = model!
            Router.pushViewController(vc: vc)
        }
        return
        #endif
        
        /// Note: To Chat
        if let contact = model,
            contact.sessionId > 0,
            contact.decodePrivateKey().count > 10 {
            if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
                vc.chatContact = contact
                Router.pushViewController(vc: vc)
            }
        }
        else {
            Toast.show(msg: "System error".localized())
        }
    }
    
    
    //MARK:- override
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + indexArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return GlobalStatusStore.shared.isShowRecommendedGroup ? 1 : 0
        }
        return self.models[indexArray[section - 1]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "recommendCell", for: indexPath)
            if let c = cell as? ContactModuleEnterCell {
                c.leftTitleL?.text = "Group recommendation".localized()
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let key = indexArray[indexPath.section - 1]
            let model = self.models[key]?[indexPath.row]
            cell?.reloadData(data: model as Any)
            cell?.selectionStyle = .none
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            toRecommendedGroup()
        } else {
            let key = indexArray[indexPath.section - 1]
            let model = self.models[key]?[indexPath.row]
            self.onTap(row: indexPath, model: model)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 22
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        let title = indexArray[safe: section - 1]
        
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let _ = header as? ContactSectionHeader {
        } else {
            header = ContactSectionHeader(reuseIdentifier: "header")
        }
        
        (header as? ContactSectionHeader)?.leftText?.text = title
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    
    //numbers
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexArray
    }
    
    //selection
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 1
    }
}

