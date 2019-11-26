







import UIKit

class ContactVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let disbag = DisposeBag()
    
    var indexArray: [String] = []
    var models: [String: [CPContact]] = [:]
    

    
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
    
    func reloadData() {
        CPContactHelper.getNormalContacts { [weak self]  (contacts) in
            
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.publicKey == support_account_pubkey  {
                    return false
                }
                return true
            }
        
            let contacts: [CPContact]? = filter

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
    
    func configUI() {
        
        self.tabBarItem.setStyle(imgName: "通讯录-未选中",
                                 selectedName: "通讯录选中",
                                 textColor: UIColor(hexString: "#BFC2CC"),
                                 selectedColor: UIColor(hexString: "#3D7EFF"))
        
        
        self.tableView.tableHeaderView = nil
        self.tableView.adjustHeader()
        self.tableView.adjustFooter()
        
        self.tableView.adjustOffset()
        self.tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        
        self.tableView.sectionIndexColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
        self.tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        
        self.tableView.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func configEvent() {
        self.scanBtn.rx.tap.subscribe(onNext: {
            #if targetEnvironment(simulator)
            Toast.show(msg: "请使用真机测试", position: .center)
            return
            #endif
            
            Authorize.canOpenCamera(autoAccess: true, result: { (can) in
                if (can) {
                    let vc = WCQRCodeVC()
                    vc.callBack = { [weak vc] (pbkey) in

                        vc?.dismiss(animated: false, completion: nil)
                        let iden = R.className(of: ContactAddVC.self) ?? ""
                        let addVc = R.loadSB(name: "Contact", iden: iden)
                        addVc.vcInitData = pbkey as AnyObject?
                        Router.pushViewController(vc: addVc)
                        
                        withUnsafeMutablePointer(to: &vc!.navigationController!.viewControllers, { (v) in
                            v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
                        })
                        
                    }
                    Router.pushViewController(vc: vc)
                }
                else {
                    Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Device_camera", comment: ""), cancelTitle: nil)
                }
            })
            
        }).disposed(by: disbag)
    }
}

extension ContactVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + indexArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section - 1 < indexArray.count {
            return self.models[indexArray[section - 1]]?.count ?? 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "observer", for: indexPath)
            return cell
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
            if let vc = R.loadSB(name: "Contact_OBV", iden: "ContactObserverListVC") as? ContactObserverListVC {
                Router.pushViewController(vc: vc)
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
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ContactSectionHeader
        header.leftText?.text = title
        
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


@objc class ContactCell: UITableViewCell {
    
    @IBOutlet weak var small: UILabel!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var smallAvatarImageV: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustOffset()
    }
    
    override func reloadData(data: Any) {
        if let d = data as? CPContact {
            remark.text = d.remark
            small.text = d.remark.getSmallRemark()
            

            if d.publicKey == support_account_pubkey {
                small.text = nil
                smallAvatarImageV?.isHidden = false
                smallAvatarImageV?.image = UIImage(named: "subscript_icon")
            } else {
                smallAvatarImageV?.isHidden = true
            }
        }
    }
}

class ContactSectionHeader: UITableViewHeaderFooterView {
    
    var leftText: UILabel?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        leftText = UILabel()
        leftText?.textColor = UIColor(hexString: "#303133")
        leftText?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(leftText!)
        
        leftText?.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self).offset(15)
            make.centerY.equalTo(self)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
