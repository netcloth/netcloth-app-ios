







import UIKit

class BlackListVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?
    
    let disbag = DisposeBag()
    
    var indexArray: [String] = []
    var models: [String: [CPContact]] = [:]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
    }
    
    func reloadData() {
        CPContactHelper.getBlackListContacts { [weak self]  (contacts) in
        
            let contacts: [CPContact]? = contacts

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
            
            self?.tableView?.reloadData()
        }
    }
    
    func configUI() {
        
        self.tableView?.adjustHeader()
        self.tableView?.adjustFooter()
        
        self.tableView?.adjustOffset()
        self.tableView?.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        
        self.tableView?.sectionIndexColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
        self.tableView?.sectionIndexTrackingBackgroundColor = UIColor.clear
        self.tableView?.sectionIndexBackgroundColor = UIColor.clear
        
        self.tableView?.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    func configEvent() {
 
    }
}

extension BlackListVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models[indexArray[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
       
       let key = indexArray[indexPath.section]
       let model = self.models[key]?[indexPath.row]
       
       cell.reloadData(data: model as Any)
       cell.selectionStyle = .none
       return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = indexArray[indexPath.section]
        let model = self.models[key]?[indexPath.row]
        
        if let contact = model {
            if let vc = R.loadSB(name: "ContactCard", iden: "ContactCardVC") as? ContactCardVC {
                vc.contactPublicKey = contact.publicKey
                Router.pushViewController(vc: vc)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let title = indexArray[safe: section]
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ContactSectionHeader
        header.leftText?.text = title
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}


extension BlackListVC {
    

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexArray
    }
    

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

}
