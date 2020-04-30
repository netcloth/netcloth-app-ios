







import UIKit

class RecommendedGroupListVC: AbstractListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Group recommendation".localized()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setSessionToRead()
    }
    
    override func configEvent() {
        super.configEvent()
         NotificationCenter.default.addObserver(self, selector: #selector(_onTriggerUnreadChange), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func _onTriggerUnreadChange() {
        self.setSessionToRead()
        NotificationCenter.post(name: NoticeNameKey.chatRoomUnreadStatusChange)
    }
    
    fileprivate func setSessionToRead() {
        CPSessionHelper.setAllReadOfSession(-1, with: SessionType.group, complete: nil)
    }
    
    
    var groupCount: Int = 0 {
        didSet {
            let count = self.groupCount
            if count == 0 {
                self.title = "Group recommendation".localized()
            } else {
                self.title = "\("Group recommendation".localized())(\(count))"
            }
        }
    }
    
    var recommendGroups: [CPRecommendedGroup]?
    
    override func requestData() {
        let contacts = self.recommendGroups?.map({ (rg) -> CPContact in
            let contact = CPContact()
            contact.publicKey = rg.group_id
            contact.sessionType = SessionType.group
            return contact
        })
        self.groupCount = contacts?.count ?? 0
        self.fillData(contacts)
    }
    
    override func cellFor(row: IndexPath) -> UITableViewCell {
        return self.tableView?.dequeueReusableCell(withIdentifier: "cell", for: row) as! RgContactCell
    }
    
    override func onTap(row: IndexPath, model: Any?) {
        if let contact = model as? CPContact {
            if let vc = R.loadSB(name: "GroupInviteDetailVC", iden: "GroupInviteDetailVC") as?  GroupInviteDetailVC ,
                let publickey = OC_Chat_Plugin_Bridge.unCompressedHexStrPubkey(ofCompressHexPubkey: contact.publicKey) {
                vc.recommended_groupPublickKey = publickey
                Router.pushViewController(vc: vc)
            }
        }
    }
}
