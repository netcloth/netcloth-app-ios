//
//  ContactAtSelectVC.swift
//  chat
//
//  Created by Grand on 2020/3/10.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class ContactAtSelectVC: GroupSelectContactVC {
    
    var atSelectBack: ((_ members: [CPContact], _ isAtAll: Bool) -> Void)?
    
    @IBOutlet weak var atAllContainerV: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.atSelectBack?([], false)
    }
    
    override func configUI() {
        super.configUI()
        self.atAllContainerV?.isHidden = true
    }
    override func reloadData() {
        filterGroupMember()
    }
    
    func filterGroupMember() {
        let selfpubkey = CPAccountHelper.loginUser()?.publicKey
        let sessionId = self.roomService?.chatContact?.value.sessionId ?? 0
        
        let isMaster  = self.roomService?.isMeGroupMaster.value ?? false
        
        CPGroupManagerHelper.getAllMemberList(inGroupSession: Int(sessionId)) { [weak self] (r, msg, list) in
            var contacts:[CPContact] = []
            let _ = list?.filter({ (member) -> Bool in
                if member.hexPubkey == selfpubkey {
                    return false
                }
                let ct = CPContact()
                ct.publicKey = member.hexPubkey
                ct.sessionId = member.sessionId
                ct.remark = member.nickName
                contacts.append(ct)
                return true
            })
            
            self?.fillData(contacts: contacts)
            
            self?.atAllContainerV?.isHidden =  !isMaster
            
        }
    }
    
    //MARK:- Action
    override func onTapDone() {
        guard let node =  IPALManager.shared.store.currentCIpal else {
            Toast.show(msg: "Please select C-IPAL first".localized())
            return
        }
        
        // select members
        var array: [CPContact] = []
        if let sindexs =  self.tableView?.indexPathsForSelectedRows {
            for indexPath in sindexs {
                let key = indexArray[indexPath.section]
                if let model = self.models[key]?[indexPath.row] {
                    array.append(model)
                }
            }
        }
        atMembers(array: array)
    }
    
    func atMembers(array: [CPContact]) {
        guard let prikey = self.roomService?.chatContact?.value.decodePrivateKey(),
            array.isEmpty == false  else {
                return
        }
        let atAll = self.viewModel.inAllSelected
        
        let callback = self.atSelectBack
        self.atSelectBack = nil
        Router.dismissVC(animate: true) {
            callback?(array, atAll)
        }
    }
    
    //MARK:- Overide
    override func lastChanceChange(cell: UITableViewCell, model: CPContact?) {
        if self.viewModel.inAllSelected == true {
            if model?.isSelected == true {
                cell.contentView.alpha = 0.6
                cell.isUserInteractionEnabled = false
            }
            else {
                cell.contentView.alpha = 1
                cell.isUserInteractionEnabled = true
            }
        }
        else {
            cell.contentView.alpha = 1
            cell.selectionStyle = .default
            cell.isUserInteractionEnabled = true
        }
    }
}
