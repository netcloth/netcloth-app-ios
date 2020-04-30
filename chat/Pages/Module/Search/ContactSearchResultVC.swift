//
//  ContactGroupSearchVC.swift
//  chat
//
//  Created by Grand on 2019/12/15.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class ContactSearchResultVC:
    BaseViewController,
    UITableViewDelegate,
    UITableViewDataSource ,
Cell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTipL: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.adjustFooter()
        self.tableView.adjustOffset()
        
        self.tableView.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    
    var contacts: [CPContact]?
    var groups: [CPContact]?
    
    func reloadData(data: Any) {
        
        if let d = data as? [CPContact] {
            
            if d.isEmpty {
                showResultEmpty()
                emptyTipL?.isHidden = false
                tableView.isHidden = true
            } else {
                tableView.isHidden = false
                emptyTipL?.isHidden = true
            }
            
            contacts = d.filter({ (contact) -> Bool in
                return contact.sessionType == SessionType.P2P
            })
            
            groups = d.filter({ (contact) -> Bool in
                return contact.sessionType == SessionType.group
            })
            
        } else {
            contacts?.removeAll()
            groups?.removeAll()
        }
        self.tableView.reloadData()
    }
    
    func showResultEmpty() {
        
        let target = ContactGroupSearchHelper.target
        if target?.isEmpty == true {
            self.emptyTipL?.attributedText = nil
            return
        }
        
        //color stranger tip
        var att1 = NSMutableAttributedString(string: "Group_Select_Empty_tip".localized())
        att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.gray_90)!], range: att1.rangeOfAll())
        
        var att2 = NSMutableAttributedString(string: "\(target!)")
        att2.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: att2.rangeOfAll())
        
        let range1 = (att1.string as? NSString)?.range(of: "#mark#")
        if let r1 = range1, r1.location != NSNotFound {
            att1.replaceCharacters(in: r1, with: att2)
        }
        self.emptyTipL?.attributedText = att1
    }
    
    
    
    func adjustOffset() {
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return contacts?.count ?? 0
        }
        return groups?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            let model = contacts?[indexPath.row]
            cell.reloadData(data: model as Any)
        }
        else {
            let model = groups?[indexPath.row]
            cell.reloadData(data: model as Any)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let rows = self.tableView(tableView, numberOfRowsInSection: section)
        if rows > 0 {
            return 40
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let rows = self.tableView(tableView, numberOfRowsInSection: section)
        if rows <= 0 {
            return nil
        }
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let _ = header as? ContactSectionHeader {
        } else {
            header = ContactSectionHeader(reuseIdentifier: "header")
        }
        
        if section == 0 {
            let title = "Concacts".localized()
            (header as? ContactSectionHeader)?.leftText?.text = title
        } else {
            let title = "Group Chats".localized()
            (header as? ContactSectionHeader)?.leftText?.text = title
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = self.view.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = self.view.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if let model = contacts?[indexPath.row] {
                toP2PChat(bySession: model)
            }
            
        }
        else {
            if let model = groups?[indexPath.row] {
                toGroupChat(bySession: model)
            }
        }
        
    }
    
    func toP2PChat(bySession session: CPContact) {
        if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC {
            vc.sessionId = Int(session.sessionId)
            vc.toPublicKey = session.publicKey
            vc.remark = session.remark
            Router.dismissVC(animate: false, completion: {
                Router.pushViewController(vc: vc)
            }, toRoot: true)
        }
    }
    
    func toGroupChat(bySession session: CPContact) {
        if let vc = R.loadSB(name: "GroupRoom", iden: "GroupRoomVC") as? GroupRoomVC {
            vc.chatContact = session
            Router.dismissVC(animate: false, completion: {
                Router.pushViewController(vc: vc)
            }, toRoot: true)
        }
    }
    
}
