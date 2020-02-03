  
  
  
  
  
  
  

import UIKit

 

class ContactVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBtn: UIButton?
    @IBOutlet weak var tableView: UITableView!
    
    let disbag = DisposeBag()
    
    var indexArray: [String] = []
    var models: [String: [CPContact]] = [:]
    
    var newFriendsCount: Int = 0 {
        didSet {
            refreshBadgeValue()
        }
    }
    
    var groupErrorCount: Int = 0 {
        didSet {
            refreshBadgeValue()
        }
    }
    
    func refreshBadgeValue() {
        let count = self.newFriendsCount + self.groupErrorCount
        if count == 0 {
            self.tabBarItem.badgeValue = nil
        } else {
            self.tabBarItem.badgeValue = "\(count)"
            self.tabBarItem.badgeColor = UIColor(hexString: "#FF4141")
        }
    }
    
    
    
    
      
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
        configEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
    }
    
    func configUI() {
        
        self.tabBarItem.setStyle(imgName: "通讯录-未选中",
                                 selectedName: "通讯录选中",
                                 textColor: UIColor(hexString: "#BFC2CC"),
                                 selectedColor: UIColor(hexString: "#3D7EFF"))
        
        
        self.tableView.tableHeaderView = nil
        self.tableView.adjustHeader()
        self.tableView.adjustFooter()
        self.tableView.adjustOffset()
        
        self.tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        
        self.tableView.sectionIndexColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
        self.tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        
        self.tableView.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func configEvent() {
        self.searchBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.onTapSearch()
        }).disposed(by: disbag)
    
        
        NotificationCenter.default.rx.notification( NoticeNameKey.newFriendsCountChange.noticeName).subscribe(onNext: { [weak self] (notice) in
            self?.reloadData()
        }).disposed(by: disbag)
    }
    
    func onTapSearch() {
        ContactGroupSearchHelper.onTapSearch()
    }
    
    func reloadData() {
        CPContactHelper.getNormalContacts { [weak self]  (contacts) in
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.publicKey == support_account_pubkey  {
                    return false
                }
                if ct.status == .strange {
                    return false
                }
                return true
            }
        
            let contacts: [CPContact]? = filter
            
              
            let newFriends = contacts?.filter({ (ct) -> Bool in
                if ct.status == .newFriend {
                    return true
                }
                return false
            })
            self?.newFriendsCount = newFriends?.count ?? 0
        
              
            self?.models.removeAll()
            if let array = contacts {
                for contact in array {
                    let title = contact.remark as NSString
                    let letters = PinyinHelper.toHanyuPinyinStringArray(withChar: title.character(at: 0)) as? [String]
                    let firstCharacter = String(letters?.first?.prefix(1) ?? (title as String).prefix(1))
                    
                    let index = firstCharacter.isEnglish() ? firstCharacter.uppercased() : "#"
                    
                    var indexArr = self?.models[index]
                    
                    if indexArr == nil {
                        indexArr = [CPContact]()
                        indexArr?.append(contact)
                        self?.models[index] = indexArr
                    } else {
                        indexArr?.append(contact)
                        self?.models[index] = indexArr
                    }
                }
            }
            
              
            let titles = self?.models.keys.sorted(by: { l, r in
                let lIsEn = l.isEnglish()
                let rIsEn = r.isEnglish()
                if lIsEn, rIsEn {
                    return l < r
                }
                return lIsEn
            })
            self?.indexArray = titles ?? []
            self?.tableView.reloadData()
        }
    }
}

extension ContactVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + indexArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        else if section - 1 < indexArray.count {
            return self.models[indexArray[section - 1]]?.count ?? 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "observer", for: indexPath)
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "groupChats", for: indexPath)
                if let c = cell as? ContactModuleEnterCell {
                    c.rightDescL?.text = "\(self.groupErrorCount)"
                    c.rightDescL?.isHidden = (self.groupErrorCount == 0)
                }
                return cell
            }
            
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newFriends", for: indexPath)
                if let c = cell as? ContactModuleEnterCell {
                    c.rightDescL?.text = "\(self.newFriendsCount)"
                    c.rightDescL?.isHidden = (self.newFriendsCount == 0)
                }
                return cell
            }
        }
        else if indexPath.section - 1  < indexArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
            
            let key = indexArray[indexPath.section - 1]
            let model = self.models[key]?[indexPath.row]
            
            cell.reloadData(data: model as Any)
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blacklist", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                if let vc = R.loadSB(name: "Contact_OBV", iden: "ContactObserverListVC") as? ContactObserverListVC {
                    Router.pushViewController(vc: vc)
                }
            }
            else if indexPath.row == 1  {
                if let vc = R.loadSB(name: "GroupList", iden: "GroupListVC") as? GroupListVC {
                    Router.pushViewController(vc: vc)
                }
            }
            else {
                if let vc = R.loadSB(name: "NewFriends", iden: "ContactNewFriendsListVC") as? ContactNewFriendsListVC {
                    Router.pushViewController(vc: vc)
                }
            }
        }
        else if indexPath.section - 1 < indexArray.count {
            
            let key = indexArray[indexPath.section - 1]
            let model = self.models[key]?[indexPath.row]
            
            if let contact = model {
                if let vc = R.loadSB(name: "ContactCard", iden: "ContactCardVC") as? ContactCardVC {
                    vc.contactPublicKey = contact.publicKey
                    Router.pushViewController(vc: vc)
                }
            }
        }
        else {
              
            if let vc = R.loadSB(name: "BlackList", iden: "BlackListVC") as? BlackListVC {
                Router.pushViewController(vc: vc)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 22
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

  
extension ContactVC {
    
      
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexArray
    }
    
      
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index + 1
    }
    

}

  
extension ContactVC {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        else if indexPath.section - 1 < indexArray.count {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.section == 0 {
            return nil
        }
        else if indexPath.section - 1 < indexArray.count {
              
            let key = indexArray[indexPath.section - 1]
            let model = self.models[key]?[indexPath.row]
            
            let remark = UITableViewRowAction(style: UITableViewRowAction.Style.normal, title: NSLocalizedString("Contact_Alias", comment: "")) { [weak self] (action, indexpath) in
                
                self?.remarkName(model)
            }
            
              
            let delete = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: NSLocalizedString("Contact_Delete", comment: "")) { [weak self] (action, indexpath) in
                self?.deleteRow(model)
            }
            
            return [delete,remark]
        }
        return nil
    }
    
      
    func deleteRow(_ contact: CPContact?) {
        
        if let contact = contact {
            
              
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                  
                alert.titleLabel?.text = NSLocalizedString("Contact_W_Title", comment: "")
                let msg = NSLocalizedString("Contact_W_msg", comment: "").replacingOccurrences(of: "#remark#", with: contact.remark)
                alert.msgLabel?.text = msg
                
                alert.cancelButton?.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
                alert.okButton?.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
                Router.showAlert(view: alert)
                
                alert.okBlock = {
                    CPContactHelper.deleteContactUser(contact.publicKey, callback: { (r, msg) in
                         self.reloadData()
                    })
                }
            }
        }
    }
    
    
    func remarkName(_ contact: CPContact?) {
        if let contact = contact {
            
              
            if let alert = R.loadNib(name: "NormalInputAlert") as? NormalInputAlert {
                  
                alert.titleLabel?.text = NSLocalizedString("Contact_Re_Title", comment: "")
    
                alert.cancelButton?.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
                alert.okButton?.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
                Router.showAlert(view: alert)
                alert.inputTextField?.placeholder = NSLocalizedString("Contact_Re_Placeholder", comment: "")
                
                alert.checkPreview = { [weak self, weak alert] in
                    if  Config.Account.checkRemarkInput(remark: alert?.inputTextField?.text) == true {
                        return true
                    }
                    else {
                        Toast.show(msg: NSLocalizedString("Contact_invalid_remark", comment: ""), position: .center)
                        return false
                    }
                }
                
                alert.okBlock = { [weak self] in
                    CPContactHelper.updateRemark(alert.inputTextField?.text ?? "", whereContactUser: contact.publicKey, callback: {  (r, msg) in
                        if r == false {
                            Toast.show(msg: msg, position: .center)
                        }
                        self?.reloadData()
                    })
                }
            }
        }
    }
}
