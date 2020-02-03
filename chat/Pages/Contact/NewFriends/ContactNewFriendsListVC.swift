  
  
  
  
  
  
  

import UIKit

class ContactNewFriendsListVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    let disbag = DisposeBag()

    var models: [CPContact] = []
    var allNewCount: Int = 0 {
        didSet {
            let count = self.allNewCount
            if count == 0 {
                self.title = "New Friends".localized()
            } else {
                self.title = "New Friends".localized() + "(\(count))"
            }
        }
    }
    
      
    deinit {
        CPContactHelper.updateAllNewfriend { (r, msg) in
            NotificationCenter.post(name: NoticeNameKey.newFriendsCountChange)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        self.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configUI() {
        
        self.tableView?.adjustHeader()
        self.tableView?.adjustFooter()
        
        self.tableView?.adjustOffset()
        self.tableView?.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        
        self.tableView?.sectionIndexColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
        self.tableView?.sectionIndexTrackingBackgroundColor = UIColor.clear
        self.tableView?.sectionIndexBackgroundColor = UIColor.clear
        
        self.tableView?.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    func configEvent() {
 
    }
    
    func reloadData() {
        CPContactHelper.getAllContacts { [weak self]  (contacts) in
            
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.status == .newFriend {
                    return true
                }
                return false
            }
            
            let contacts: [CPContact]? = filter
            self?.models.removeAll()
            self?.models = contacts ?? []
           
            self?.tableView?.reloadData()
        }
    }
    
}

extension ContactNewFriendsListVC {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        let model = self.models[safe:indexPath.row]
       
       cell.reloadData(data: model as Any)
       cell.selectionStyle = .none
       return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.models[safe: indexPath.row]
        if let ct = model {
            let pubkey = ct.publicKey
            if let vc = R.loadSB(name: "ContactCard", iden: "ContactCardVC") as? ContactCardVC{
                vc.contactPublicKey = pubkey
                Router.pushViewController(vc: vc)
            }
            ct.haveReadNewFriends = true
            tableView.reloadRow(at: indexPath, with: .none)
            dealAllNewCount()
        }
    }
    
    func dealAllNewCount() {
        var c = 0
        for item in models {
            if item.haveReadNewFriends == false {
                c += 1
            }
        }
        self.allNewCount = c
    }
}

extension ContactNewFriendsListVC {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return CGFloat.leastNonzeroMagnitude
       }
       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           return nil
       }
       
       func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return CGFloat.leastNonzeroMagnitude
       }
       func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           return nil
       }
}
