//
//  StrangerSessionListVC.swift
//  chat
//
//  Created by Grand on 2019/11/22.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class StrangerSessionListVC: BaseViewController {
    
    class ViewModel: NSObject {
        @objc dynamic var inEditable:Bool = false
        @objc dynamic var multiSelectedCount:Int = 0
        var inAllSelected:Bool = false
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomV: UIView?
    
    @IBOutlet weak var allSelectBtn: UIButton?
    @IBOutlet weak var deleteBtn: UIButton?
    
    
    var viewModel = ViewModel()
    var sessionsArray : [CPSession]?
    var sessionQueue : DispatchQueue = OS_dispatch_queue_serial(label: "com.chat.session", qos: .default)
    
    let disbag = DisposeBag()
    
    deinit {
        self.navigationItem.hidesBackButton = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        self.showLoading()
        configEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTable()
    }
    
    //MARK:- Binding
    @objc func onTapEdit() {
        self.viewModel.inEditable = !self.viewModel.inEditable
    }
    
    
    var allUnreadCount: Int = 0 {
        didSet {
            let count = self.allUnreadCount
            if count == 0 {
                self.title = "Stranger Messages".localized()
            } else {
                self.title = "\("Stranger Messages".localized())(\(count))"
            }
        }
    }
    
    
    //MARK:- Config
    func configUI() {
        self.tableView.adjustFooter()
        self.tableView.adjustOffset()
        
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        let barItem = UIBarButtonItem(title: "Edit".localized(), style: .plain, target: self, action: #selector(onTapEdit))
        barItem.tintColor = UIColor(hexString: Color.blue)
        self.navigationItem.rightBarButtonItem = barItem
        
        self.bottomV?.setShadow(color: UIColor.lightGray, offset: CGSize(width: 0,height: -5), radius: 5, opacity: 0.1)
    }
    
    func configEvent() {
        self.viewModel.rx.observe(Bool.self, "inEditable").subscribe { [weak self] (event) in
            if event.element == true {
                self?.tableView.setEditing(true, animated: true)
                self?.navigationItem.rightBarButtonItem?.title = "Cancel".localized()
                self?.navigationItem.hidesBackButton = true
                self?.bottomV?.isHidden = false
            } else {
                self?.tableView.setEditing(false, animated: true)
                self?.navigationItem.rightBarButtonItem?.title = "Edit".localized()
                self?.navigationItem.hidesBackButton = false
                self?.bottomV?.isHidden = true
                self?.viewModel.inAllSelected = false
            }
        }
        .disposed(by: disbag)
        
        self.viewModel.rx.observe(Int.self, "multiSelectedCount").map { (num) -> Bool in
            if let n = num, n > 0 {
                return true
            }
            return false
            }
        .bind(to: self.deleteBtn!.rx.isEnabled)
        .disposed(by: disbag)
        
        self.allSelectBtn?.rx.tap.subscribe({ [weak self] (event) in
            self?.viewModel.inAllSelected = !(self?.viewModel.inAllSelected ?? false)
            let allIn = (self?.viewModel.inAllSelected ?? false)
            if allIn {
                if let enumer = self?.sessionsArray?.enumerated() {
                    for (index, item) in enumer {
                        self?.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
                    }
                    self?.viewModel.multiSelectedCount = self?.sessionsArray?.count ?? 0
                }
            } else {
                self?.tableView.clearSelectedRows(animated: true)
                self?.viewModel.multiSelectedCount = 0
            }
        }).disposed(by: disbag)
        
        self.deleteBtn?.rx.tap.subscribe({ [weak self] (event) in
            guard let selectRows = self?.tableView.indexPathsForSelectedRows else {
                return
            }
            
            var toDels = [CPSession]()
            selectRows.forEach({ (indexpath) in
                if let t = self?.sessionsArray?[safe: indexpath.row] {
                    toDels.append(t)
                }
            })
            for item in toDels {
                if let index = self?.sessionsArray?.firstIndex(of: item) {
                    self?.sessionsArray?.remove(at: index)
                }
            }
            
            self?.tableView.deleteRows(at: selectRows, with: .fade)
            
            self?.showLoading()
            var delsessions = toDels.map { (session) -> NSNumber in
                return NSNumber(integerLiteral: Int(session.sessionId))
            }
            CPSessionHelper.deleteSessions(delsessions) { (r, msg) in
                self?.dismissLoading()
            }
            CPContactHelper.onlyDeleteContacts(inSessionIds: delsessions, callback: nil)
            
            self?.viewModel.multiSelectedCount = self?.tableView?.indexPathsForSelectedRows?.count ?? 0
            if self?.sessionsArray?.isEmpty == true {
                self?.viewModel.inEditable = false
            }
            
        }).disposed(by: disbag)
    }
    
    func reloadTable() {
        
        CPSessionHelper.getStrengerAllSessionComplete { [weak self] (ok:Bool, msg, array:[CPSession]?) in
            self?.sessionQueue.async {
//
                
                var array = array?.filter({ (session) -> Bool in
                    if session.relateContact.status == .strange {
                        return true
                    }
                    
                    if session.relateContact.status == .assistHelper {
                        if let _ = session.relateContact.publicKey.isCurNodeAssist() {
                            
                        } else {
                            return true
                        }
                    }
                    return false
                })
                
                //recovery
                if let havedarr = self?.sessionsArray, let toinarr = array {
                    for have in havedarr {
                        for toin in toinarr {
                            if have.sessionType == toin.sessionType &&
                                have.lastMsgId == toin.lastMsgId &&
                                have.lastMsg?.msgId == toin.lastMsg?.msgId {
                                toin.lastMsg = have.lastMsg
                                break;
                            }
                        }
                    }
                }
                
                //decode
                var count = 0
                if let toinarr = array {
                    for toin in toinarr {
                        count += toin.unreadCount
                    }
                }
                
                self?.sessionsArray = array
                DispatchQueue.main.async {
                    self?.dismissLoading()
                    self?.allUnreadCount = count
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension StrangerSessionListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = sessionsArray?[safe: indexPath.row] as Any
        let cellId = "SessionCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.reloadData(data: data)
       
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard viewModel.inEditable == false else {
            viewModel.multiSelectedCount = tableView.indexPathsForSelectedRows?.count ?? 0
            return
        }
        tableView.deselectRow(at: indexPath, animated: false)
        if let session = sessionsArray?[safe: indexPath.row] {
            if let vc = R.loadSB(name: "ChatRoom", iden: "ChatRoomVC") as? ChatRoomVC {
                vc.sessionId = Int(session.sessionId)
                vc.toPublicKey = session.relateContact.publicKey
                vc.remark = session.relateContact.remark
                Router.pushViewController(vc: vc)
            }
        }
        else {
            print("didSelectRowAt \(indexPath.row)")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard viewModel.inEditable == false else {
            viewModel.multiSelectedCount = tableView.indexPathsForSelectedRows?.count ?? 0
            return
        }
    }
}

extension StrangerSessionListVC {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: 3) ?? .delete
    }
}
