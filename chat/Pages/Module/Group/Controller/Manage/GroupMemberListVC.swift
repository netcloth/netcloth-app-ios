







import UIKit

class GroupMemberListVC:BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchHeaderContainer: UIView?
    @IBOutlet weak var searchImageV: UIImageView?
    @IBOutlet weak var inputSearch: UITextField?
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var resultContainer: UIView?
    @IBOutlet weak var searchResultTable: UITableView?
    @IBOutlet weak var emptyTipL: UILabel?
    
    @IBOutlet weak var addMemberControl: UIControl?
    @IBOutlet weak var delMemberControl: UIControl?
    
    var models: [CPGroupMember] = []
    let disbag = DisposeBag()
    
    
    deinit {
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
        
        let taskExe = { (tableView: UITableView?, setDelegate: Bool ) in
            
            tableView?.adjustFooter()
            tableView?.adjustOffset()
            
            tableView?.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
            tableView?.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
            
            tableView?.sectionIndexColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
            tableView?.sectionIndexTrackingBackgroundColor = UIColor.clear
            tableView?.sectionIndexBackgroundColor = UIColor.clear
            
            tableView?.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
            
            if setDelegate {
                tableView?.delegate = self
                tableView?.dataSource = self
            }
            
        }
        
        taskExe(self.tableView, true)
        taskExe(self.searchResultTable, false)
        self.resultContainer?.isHidden = true
    }
    
    func configEvent() {
        
        self.roomService?.isMeGroupMaster.map({ [weak self] (isMaster) -> Bool in
            if isMaster {
                self?.tableView?.tableHeaderView?.height = 160
            } else {
                self?.tableView?.tableHeaderView?.height = 80
            }
            return !isMaster
            }).bind(to: self.delMemberControl!.rx.isHidden).disposed(by: disbag)
        
        
        
        let searchDriver =
            self.inputSearch?.rx.value
                .asDriver()
                .distinctUntilChanged()
                .throttle(RxTimeInterval.milliseconds(300))
                .flatMapLatest({ [weak self] (input) -> Driver<[CPGroupMember]>  in
                    return (self?.queryLocalContact(input: input).asDriver(onErrorJustReturn: []) ??
                        Observable.empty().asDriver(onErrorJustReturn: []))
                })
        
        
        searchDriver?.drive(searchResultTable!.rx.items(cellIdentifier: "cell",cellType: ContactCell.self)) { [weak self] ( row, model, cell) in
            cell.multipleSelectionBackgroundView = UIView()
            cell.reloadData(data: model)
        }.disposed(by: disbag)
        
        
        Observable.of((self.searchResultTable?.rx.modelSelected(CPGroupMember.self))!,
                      (self.searchResultTable?.rx.modelDeselected(CPGroupMember.self))!).merge()
            .subscribe(onNext: { [weak self](contact) in
                self?.onResultSelectedSearchModel(contact)
            }).disposed(by: disbag)
        
        
        searchDriver?.drive(onNext: { [weak self] (result) in
            let target = self?.inputSearch?.text
            if target?.isEmpty == true {
                self?.resultContainer?.isHidden = true
            } else {
                self?.resultContainer?.isHidden = false
                
                if result.isEmpty == true {
                    self?.searchResultTable?.isHidden = true
                    self?.showResultEmpty()
                } else {
                    self?.searchResultTable?.isHidden = false
                }
            }
        }).disposed(by: disbag)
        
        
        self.addMemberControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            let isMaster = self?.roomService?.isMeGroupMaster.value
            let inviteType = self?.roomService?.chatContact?.value.inviteType
            if isMaster == false,
                inviteType == CPGroupInviteType.onlyOwner.rawValue {
                InnerHelper.showOnlyGroupAdminInviteTip()
                return
            }
            if let vc = R.loadSB(name: "GroupInviteFriendsVC", iden: "GroupInviteFriendsVC") as? GroupInviteFriendsVC {
                Router.pushViewController(vc: vc)
            }
        }).disposed(by: disbag)
        
        self.delMemberControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            if let vc = R.loadSB(name: "GroupInviteFriendsVC", iden: "GroupInviteFriendsVC") as? GroupInviteFriendsVC {
                vc.pageTag = 1
                Router.pushViewController(vc: vc)
            }
        }).disposed(by: disbag)
    }
    
    func reloadData() {
        let  sessionId = self.roomService?.chatContact?.value.sessionId ?? 0
        CPGroupManagerHelper.getAllMemberList(inGroupSession: Int(sessionId), callback: { [weak self] (r, msg, members) in
            let contacts: [CPGroupMember]? = members
            self?.models.removeAll()
            self?.models = contacts ?? []
            self?.tableView?.reloadData()
            self?.memberCount = contacts?.count ?? 0
        })
    }
    
    var memberCount: Int = 0 {
        didSet {
            let count = self.memberCount
            if count == 0 {
                self.title = "Group Members".localized()
            } else {
                self.title = "\("Group Members".localized())(\(count))"
            }
        }
    }
    
    
    
    
    

    
    
    
    func queryLocalContact(input: String?) -> Observable<[CPGroupMember]> {
        return Observable<[CPGroupMember]>.create { [weak self] (observer) -> Disposable in
            DispatchQueue.global().async {
                var array: [CPGroupMember] = []
                if let s = input?.lowercased(), let collection = self?.models {
                    for item in  collection {
                       if item.nickName.lowercased().contains(s) {
                           array.append(item)
                       }
                    }
                }
                observer.onNext(array)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    
    func showResultEmpty() {
        
        let target = self.inputSearch?.text
        if target?.isEmpty == true {
            self.emptyTipL?.attributedText = nil
            return
        }
        
        
        var att1 = NSMutableAttributedString(string: "Group_Member_Select_Empty_tip".localized())
        att1.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.gray_90)!], range: att1.rangeOfAll())
        
        var att2 = NSMutableAttributedString(string: "\(target!)")
        att2.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: att2.rangeOfAll())
        
        let range1 = (att1.string as? NSString)?.range(of: "#mark#")
        if let r1 = range1, r1.location != NSNotFound {
            att1.replaceCharacters(in: r1, with: att2)
        }
        self.emptyTipL?.attributedText = att1
    }
    
    func onResultSelectedSearchModel(_ contact: CPGroupMember) {
        
        self.inputSearch?.text = nil
        self.inputSearch?.resignFirstResponder()
        self.inputSearch?.sendActions(for: UIControl.Event.editingDidEnd)
        
        toGroupMemberInfo(info: contact)

    }
    
    
    func toGroupMemberInfo(info: CPGroupMember?) {
        if let ct = info {
            let pubkey = ct.hexPubkey
            if let vc = R.loadSB(name: "GroupMemberCard", iden: "GroupMemberCardVC") as? GroupMemberCardVC {
                vc.contactPublicKey = pubkey
                Router.pushViewController(vc: vc)
            }
            
        }
    }
}

extension GroupMemberListVC {
    

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
        toGroupMemberInfo(info: model)
    }
    
}

extension GroupMemberListVC {
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
