//
//  GroupSelectContactVC.swift
//  chat
//
//  Created by Grand on 2019/11/29.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

//create
class GroupSelectContactVC: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    class ViewModel: NSObject {
        @objc dynamic var inSearch: Bool = false
        @objc dynamic var multiSelectedCount: Int = 0
        var inAllSelected:Bool = false
    }
    
    weak var doneBtn: UIButton?
    @IBOutlet weak var searchHeaderContainer: UIView?
    @IBOutlet weak var searchImageV: UIImageView?
    @IBOutlet weak var inputSearch: UITextField?
    @IBOutlet weak var countLabel: UILabel?
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var resultContainer: UIView?
    @IBOutlet weak var searchResultTable: UITableView?
    @IBOutlet weak var emptyTipL: UILabel?
    
    @IBOutlet weak var allSelectBtn: UIButton?
    
    var indexArray: [String] = []
    var models: [String: [CPContact]] = [:]
    fileprivate var totalCount: Int = 0
    
    var viewModel = ViewModel()
    let disbag = DisposeBag()
    
    var stop:Bool = false
    var groupName: String?
    //MARK:- Life Cycle
    deinit {
        stop = true
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
    
    func reloadData() {
        CPContactHelper.getNormalContacts { [weak self]  (contacts) in
            let filter =  contacts.filter { (ct) -> Bool in
                if ct.status == .assistHelper ||
                    ct.status == .strange {
                    return false
                }
                return true
            }
            let contacts: [CPContact]? = filter
            self?.fillData(contacts: contacts)
        }
    }
    
    func fillData(contacts: [CPContact]?) {
        self.totalCount = contacts?.count ?? 0
        self.models.removeAll()
        if let array = contacts {
            for contact in array {
                
                let index = InnerHelper.converStringToPinYin(inString: contact.remark)
                var indexArr = self.models[index]
                contact.pinyinIndex = index
                
                if indexArr == nil {
                    indexArr = [CPContact]()
                    indexArr?.append(contact)
                    self.models[index] = indexArr
                } else {
                    indexArr?.append(contact)
                    self.models[index] = indexArr
                }
            }
        }
        
        //sort index
        let titles = self.models.keys.sorted(by: { l, r in
            let lIsEn = l.isEnglish()
            let rIsEn = r.isEnglish()
            if lIsEn, rIsEn {
                return l < r
            }
            return lIsEn
        })
        self.indexArray = titles ?? []
        self.tableView?.reloadData()
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
            //edite
            tableView?.allowsMultipleSelectionDuringEditing = true
            tableView?.setEditing(true, animated: true)
        }
        
        taskExe(self.tableView, true)
        taskExe(self.searchResultTable, false)
        self.resultContainer?.isHidden = true
        
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(onTapDone), for: .touchUpInside)
        btn.setTitle("Done".localized(), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.backgroundColor = UIColor(hexString: Color.blue)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.layer.cornerRadius = 4
        btn.size.height = 32
        doneBtn = btn
        
        
        let barItem = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItem = barItem
        
    }
    
    func configEvent() {
        
        viewModel.rx.observe(Int.self, "multiSelectedCount").subscribe(onNext: { [weak self] (count) in
            if let c = count, c >= 1 {
                self?.doneBtn?.alpha = 1
                self?.doneBtn?.isEnabled = true
                self?.countLabel?.isHidden = false
                self?.resetCountLabel(sCount: c)
            }
            else {
                self?.doneBtn?.alpha = 1
                self?.doneBtn?.isEnabled = true
                self?.countLabel?.isHidden = true
            }
        }).disposed(by: disbag)
        
        self.allSelectBtn?.rx.tap.subscribe({ [weak self] (event) in
            self?.viewModel.inAllSelected = !(self?.viewModel.inAllSelected ?? false)
            let allIn = (self?.viewModel.inAllSelected ?? false)
            if allIn {
                self?.tableSelectAll(isAll: true)
                self?.viewModel.multiSelectedCount =  self?.totalCount ?? 0
            }
            else {
                self?.tableSelectAll(isAll: false)
                self?.viewModel.multiSelectedCount = 0
            }
        }).disposed(by: disbag)
        
        //for search able
        let searchDriver =
            self.inputSearch?.rx.value
                .asDriver()
                .distinctUntilChanged()
                .throttle(RxTimeInterval.milliseconds(300))
                .flatMapLatest({ [weak self] (input) -> Driver<[CPContact]>  in
                    return (self?.queryLocalContact(input: input).asDriver(onErrorJustReturn: []) ??
                        Observable.empty().asDriver(onErrorJustReturn: []))
                })
        
        //reload table
        searchDriver?.drive(searchResultTable!.rx.items(cellIdentifier: "cell",cellType: ContactCell.self)) { [weak self] ( row, model, cell) in
            cell.multipleSelectionBackgroundView = UIView()
            cell.reloadData(data: model)
            self?.lastChanceChange(cell: cell, model: model)
        }.disposed(by: disbag)
        
        //table selected
        Observable.of((self.searchResultTable?.rx.itemSelected)!,
                      (self.searchResultTable?.rx.itemDeselected)!).merge()
            .subscribe(onNext: { [weak self] (indexpath) in
                self?.searchResultTable?.selectRow(at: indexpath, animated: false, scrollPosition: .none)
            }).disposed(by: disbag)
        
        Observable.of((self.searchResultTable?.rx.modelSelected(CPContact.self))!,
                      (self.searchResultTable?.rx.modelDeselected(CPContact.self))!).merge()
            .subscribe(onNext: { [weak self](contact) in
                self?.onResultSelectedSearchModel(contact)
            }).disposed(by: disbag)
        
        //on search change
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
                
                //selected
                for index in 0 ..< result.count {
                    if let item = result[index] as? CPContact, item.isSelected {
                        self?.searchResultTable?.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
                    }
                }
            }
        }).disposed(by: disbag)
        
    }
    
    func lastChanceChange(cell: UITableViewCell, model: CPContact?) {
        
    }
    
    fileprivate func tableSelectAll(isAll: Bool) {
        let inArray = self.indexArray
        let modelArray = self.models
        for index in inArray {
            if let section = inArray.firstIndex(of: index),
                let rows = modelArray[index] {
                for value in rows {
                    value.isSelected = isAll
                    if let row = rows.firstIndex(of: value) {
                        let indexpath = IndexPath(row: row, section: section)
                        if isAll {
                            self.tableView?.selectRow(at: indexpath, animated: true, scrollPosition: .none)
                        }
                        else {
                            self.tableView?.deselectRow(at: indexpath, animated: true)
                        }
                        if let cell = self.tableView?.cellForRow(at: indexpath) {
                            self.lastChanceChange(cell: cell, model: value)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK:- Create Group
    /// Helper
    func showAnimate(tip: String) {
        if let view = R.loadNib(name: "WaitAlert") as? WaitAlert {
            view.bottomL?.text = tip
            Router.showAlert(view: view)
        }
    }
    
    func dissmissAnimate(complete: (() -> Void)?) {
        Router.dismissVC(animate: false, completion: complete)
    }
    
    func showFail(tip: String) {
        self.dissmissAnimate {
            if let v = R.loadNib(name: "ImageAlert") as? ImageAlert {
                v.imageV?.image = UIImage(named: "create_fail")
                v.bottomL?.text = tip
                Router.showAlert(view: v)
            }
        }
    }

    
    @objc func onTapDone() {
        
        guard let node =  IPALManager.shared.store.currentCIpal else {
            Toast.show(msg: "Please select C-IPAL first".localized())
            return
        }
        
        self.showAnimate(tip: "Creating group chat, please wait…".localized())
        
        var array: [String] = [];
        if let sindexs =  self.tableView?.indexPathsForSelectedRows {
            for indexPath in sindexs {
                let key = indexArray[indexPath.section]
                if let model = self.models[key]?[indexPath.row] {
                    array.append(model.publicKey)
                }
            }
        }
        
        //create account
        let privateKey = OC_Chat_Plugin_Bridge.createPrivatekey()
        let pubkey = OC_Chat_Plugin_Bridge.hexPublicKey(fromPrivatekey: privateKey)
        
        let nickname = CPAccountHelper.loginUser()?.accountName ?? ""
        let groupname = self.groupName ?? "hello world"
        
        //本地创建
        CPGroupManagerHelper.createNormalGroup(byGroupName: groupname,
                                               ownerNickName: nickname,
                                               groupPrivateKey: privateKey,
                                               groupProgress: .unknown,
                                               serverAddress: node.operator_address) { (r, msg, contact) in
                                                if r == false {
                                                    self.showFail(tip: msg)
                                                    CPContactHelper.deleteContactUser(pubkey, callback: nil)
                                                    return;
                                                }
                                                self.step2Bind(node: node,
                                                               privateKey: privateKey, pubkey: pubkey,
                                                               groupname: groupname,
                                                               nickname: nickname,
                                                               array: array,
                                                               contact: contact)
        }
    }
    
    
    
    fileprivate func step2Bind(node: IPALNode, privateKey: Data, pubkey: String,
                               groupname:String,
                               nickname: String,
                               array: [String],
                               contact: CPContact?) {
        //Note 绑定ipal
        ChainService.ipalBind(node: node,
                              bindType: 2,
                              byPrivateKey: privateKey)
            .done({ (txHash) in
                CPGroupManagerHelper.updateGroupProgress(.sendIPAL, orIpalHash: txHash, byPubkey: pubkey, callback: nil)
                
                //Note 查询ipal 状态
                IPALManager.shared.v2_getIPALStatusInfo(txHash: txHash,
                                                        requestCount: 0,
                                                        autoUpdateDB: false,
                                                        stop: &self.stop) { (suc) in
                    
                    if suc == true {
                        CPGroupManagerHelper.updateGroupProgress(.IPALOK, orIpalHash: nil, byPubkey: pubkey, callback: nil)
                        
                        self.step3SendCreateMsg(privateKey: privateKey, pubkey: pubkey,
                                           groupname: groupname,
                                           nickname: nickname,
                                           array: array,
                                           contact: contact)
                    }
                    else {
                        self.showFail(tip: "C-IPAL registration failed".localized())
                        
                        CPGroupManagerHelper.updateGroupProgress(.ipalFail, orIpalHash: nil, byPubkey: pubkey, callback: nil)
                        CPContactHelper.deleteContactUser(pubkey, callback: nil)
                    }
                }
            })
            .catch { (err) in
                self.showFail(tip: "C-IPAL registration failed".localized())
                CPGroupManagerHelper.updateGroupProgress(.ipalFail, orIpalHash: nil, byPubkey: pubkey, callback: nil)
                CPContactHelper.deleteContactUser(pubkey, callback: nil)
        }
    }
    
    func step3SendCreateMsg(privateKey: Data, pubkey: String,
                            groupname:String,
                            nickname: String,
                            array: [String],
                            contact: CPContact?) {
        //Note 发送创建请求to server
        CPGroupChatHelper.sendCreateGroupNotify(groupname,
                                                type: 0,
                                                ownerNickName: nickname,
                                                inviteeUsers: array,
                                                groupPrivateKey: privateKey) { [weak self] (response) in
            let json = JSON(response)
            if let code = json["code"].int ,
                (code == ChatErrorCode.OK.rawValue ||
                    code == ChatErrorCode.groupDuplicate.rawValue) {
                
                self?.dissmissAnimate(complete: {
                    CPGroupManagerHelper.updateGroupProgress(.createOK,
                                                             orIpalHash: nil,
                                                             byPubkey: pubkey,
                                                             callback: nil)
                    
                    
                    //fake send Welcome Msg
                    let msg = CPMessage()
                    msg.senderPubKey = CPAccountHelper.loginUser()?.publicKey ?? ""
                    msg.toPubkey = pubkey
                    msg.msgType = .createGroupSuccess
                    msg.msgData = "Group_Create_Suc_tip".localized().data(using: String.Encoding.utf8)
                    msg.signHash = OC_Chat_Plugin_Bridge.getRandomSign()
                    
                    CPGroupChatHelper.fakeSendMsg(msg, complete: nil)
                    
                    //fake add group master
                    if let gc = contact {
                        let gm = CPGroupMember()
                        gm.sessionId = gc.sessionId
                        gm.hexPubkey = CPAccountHelper.loginUser()?.publicKey ?? "";
                        gm.nickName = nickname;
                        gm.role =  GroupRole.owner
                        //Note: time
                        gm.join_time =  Int64(NSDate().timeIntervalSince1970 * 1000);
                        CPGroupManagerHelper.insertOrReplaceOneGroupMember(gm, callback: nil)
                    }
                    
                    //to success page
                    if let vc = R.loadSB(name: "GroupCreate", iden: "GroupCreateResponseVC") as? GroupCreateResponseVC {
                        contact?.groupProgress = .createOK
                        GroupRoomService.createdGroup = contact
                        Router.pushViewController(vc: vc)
                    }
                })
            }
            else {
                self?.showFail(tip: "Group_Server_Con_fail".localized())
                
                CPGroupManagerHelper.updateGroupProgress(.createFail, orIpalHash: nil, byPubkey: pubkey, callback: nil)
                CPContactHelper.deleteContactUser(pubkey, callback: nil)
            }
        }
    }
    
    
    //MARK:- Helper
    func queryLocalContact(input: String?) -> Observable<[CPContact]> {
        return Observable<[CPContact]>.create { [weak self] (observer) -> Disposable in
            DispatchQueue.global().async {
                var array: [CPContact] = []
                if let s = input?.lowercased(), let collection = self?.models {
                    for (_, item) in  collection {
                        for ct in item {
                            if ct.remark.lowercased().contains(s) || ct.pinyinIndex.lowercased().contains(s) {
                                array.append(ct)
                            }
                        }
                    }
                }
                observer.onNext(array)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func resetCountLabel(sCount: Int) {
        //color stranger tip
        var att1 = NSMutableAttributedString(string: "Group_Select_Count".localized())
        
        var att2 = NSMutableAttributedString(string: "\(sCount)")
        att2.addAttributes([NSAttributedString.Key.foregroundColor : UIColor(hexString: Color.blue)!], range: att2.rangeOfAll())
        
        let range1 = (att1.string as? NSString)?.range(of: "#mark#")
        if let r1 = range1, r1.location != NSNotFound {
            att1.replaceCharacters(in: r1, with: att2)
        }
        self.countLabel?.attributedText = att1
    }
    
    func showResultEmpty() {
        
        let target = self.inputSearch?.text
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
    
    func onResultSelectedSearchModel(_ contact: CPContact) {
        
        self.inputSearch?.text = nil
        self.inputSearch?.resignFirstResponder()
        self.inputSearch?.sendActions(for: UIControl.Event.editingDidEnd)
        
        for (_, array) in self.models {
            for ct in array {
                if ct.publicKey == contact.publicKey {
                    ct.isSelected = true
                    let key = InnerHelper.converStringToPinYin(inString: ct.remark)
                    let section = self.indexArray.firstIndex(of: key)
                    let row = array.firstIndex(of: ct)
                    
                    if let s = section, let r = row {
                        self.tableView?.selectRow(at: IndexPath(row: r, section: s), animated: false, scrollPosition: UITableView.ScrollPosition.middle)
                    }
                    self.handleSelectedChange()
                    return
                }
            }
        }
    }
    
}

//MARK:- DataSource
extension GroupSelectContactVC {
    
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
        
        cell.multipleSelectionBackgroundView = UIView()
        
        lastChanceChange(cell: cell, model: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelectedChange()
        let key = indexArray[indexPath.section]
        let model = self.models[key]?[indexPath.row]
        model?.isSelected = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        handleSelectedChange()
        let key = indexArray[indexPath.section]
        let model = self.models[key]?[indexPath.row]
        model?.isSelected = false
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = indexArray[safe: section]
        
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let _ = header as? ContactSectionHeader {
        } else {
            header = ContactSectionHeader(reuseIdentifier: "header")
        }
        
        (header as? ContactSectionHeader)?.leftText?.text = title
        header?.contentView.backgroundColor = UIColor(hexString: "#F2F3F4")
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func handleSelectedChange() {
        let sPaths = self.tableView?.indexPathsForSelectedRows
        let count  = sPaths?.count ?? 0
        viewModel.multiSelectedCount = count
        self.viewModel.inAllSelected =  false
    }
}

//MARK:- Index
extension GroupSelectContactVC {
    
    //numbers
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexArray
    }
    
    //selection
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}

//MARK:- Editable
extension GroupSelectContactVC {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: 3) ?? .delete
    }
}
