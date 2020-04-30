//
//  MsgAlertSettingVC.swift
//  chat
//
//  Created by Grand on 2019/8/28.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

class MsgAlertSettingVC: BaseTableViewController {
    
    @IBOutlet weak var shakeSwitch: UISwitch!
    @IBOutlet weak var bellSwitch: UISwitch!
    @IBOutlet weak var muteAndBlack: UISwitch!
    @IBOutlet weak var bTipL: UILabel?
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        refreshCells()
        configEvent()
    }
    
    func configUI() {
        self.tableView.backgroundColor = UIColor(hexString: "#F7F7F7")
        config(self.shakeSwitch)
        config(self.bellSwitch)
        config(self.muteAndBlack)
        
        bTipL?.preferredMaxLayoutWidth = YYScreenSize().width - 30
        bTipL?.numberOfLines = 0
//        self.tableView.tableFooterView?.setNeedsLayout()
    }
    
    func config(_ _switch: UISwitch) {
        _switch.onTintColor = UIColor(hexString: Color.blue)
        _switch.tintColor = UIColor(hexString: "#E1E4E9")
    }
    
    func configEvent() {
        shakeSwitch.rx.value.subscribe(onNext: { (isOn) in
            Config.Settings.shakeble = isOn
        }).disposed(by: disbag)
        
        bellSwitch.rx.value.subscribe(onNext: { (isOn) in
            Config.Settings.bellable = isOn
        }).disposed(by: disbag)
        
        muteAndBlack.rx.value.skip(1).subscribe(onNext: { [weak self] (isOn) in
            if isOn {
                self?.onOpenNotify()
            }
            else {
                self?.onCloseNotify()
            }
        }).disposed(by: disbag)
    }
 
    func refreshCells() {
        shakeSwitch.isOn = Config.Settings.shakeble
        bellSwitch.isOn = Config.Settings.bellable
        muteAndBlack.isOn = Config.Settings.muteBlackAble
    }
    
    //MARK:- Action
    func onCloseNotify() {
        self.popConfirmAlert().done { (result) in
            self.closeTask()
        }.catch { error in
            self.muteAndBlack.isOn = true
            Config.Settings.muteBlackAble = true
        }
    }
    
    func onOpenNotify() {
        self.openTask()
    }
    
    /// default close notify
    fileprivate func closeTask() {
        self.showLoading()
        CPContactHelper.getMuteList {(p2p, group) in
            when(fulfilled: self.uploadBlackList(),
                 self.uploadP2PMute(array: p2p ?? []),
                 self.uploadGroupMute(array: group ?? []))
            .done { (arg0) in
                    Config.Settings.muteBlackAble = false
            }
            .catch { (error) in
                Toast.show(msg: "System error".localized())
                self.muteAndBlack.isOn = true
                Config.Settings.muteBlackAble = true
            }
            .finally {
                self.dismissLoading()
            }
        }
    }
    
    fileprivate func openTask() {
        self.showLoading()
        CPContactHelper.getMuteList {(p2p, group) in
            when(fulfilled: self.uploadBlackList(openNotify: true),
                 self.uploadP2PMute(array: p2p ?? [], openNotify: true),
                 self.uploadGroupMute(array: group ?? [], openNotify: true))
                .done { (arg0) in
                    Config.Settings.muteBlackAble = true
            }
            .catch { (error) in
                Toast.show(msg: "System error".localized())
                self.muteAndBlack.isOn = false
                Config.Settings.muteBlackAble = false
            }
            .finally {
                self.dismissLoading()
            }
        }
    }
    
    
    //MARK:-
    fileprivate func uploadBlackList(openNotify: Bool = false) -> Promise<String> {
        let action: NCProtoActionType = openNotify ? .actionTypeDelete : .actionTypeAdd
        
        let _promise = Promise<String> { ( resolver :Resolver<String>) in
            CPContactHelper.getBlackListContacts { (array) in
                if array.isEmpty {
                    resolver.fulfill("ok")
                }
                else {
                    let hexarray = array.map { (contact) -> String in
                        return contact.publicKey
                    }
                    CPHttpReqHelper.requestSetBlackBatch(action, related_pub_keys: hexarray) { (r, msg, rsp) in
                        if let code = rsp?.result,
                            code == ChatErrorCode.OK.rawValue {
                            resolver.fulfill("ok")
                        }
                        else {
                            resolver.reject(NSError(domain: "error", code: 2, userInfo: nil))
                        }
                    }
                }
            }
        }
        return _promise
    }
    
    
    fileprivate func uploadP2PMute(array: [CPContact], openNotify: Bool = false) -> Promise<String> {
        let action: NCProtoActionType = openNotify ? .actionTypeDelete : .actionTypeAdd
        let _promise = Promise<String> { ( resolver :Resolver<String>) in
            if array.isEmpty {
                resolver.fulfill("ok")
            }
            else {
                let hexarray = array.map { (contact) -> String in
                    return contact.publicKey
                }
                CPHttpReqHelper.requestSetMuteNotificationBatch(action,
                                                                type: NCProtoChatType.chatTypeSingle,
                                                                related_pub_keys: hexarray)  { (r, msg, rsp) in
                                                                    if let code = rsp?.result,
                                                                        code == ChatErrorCode.OK.rawValue {
                                                                        resolver.fulfill("ok")
                                                                    }
                                                                    else {
                                                                        resolver.reject(NSError(domain: "error", code: 2, userInfo: nil))
                                                                    }
                }
            }
        }
        return _promise
    }
    
    fileprivate func uploadGroupMute(array: [CPContact],openNotify: Bool = false) -> Promise<String> {
        let action: NCProtoActionType = openNotify ? .actionTypeDelete : .actionTypeAdd
        let _promise = Promise<String> { ( resolver :Resolver<String>) in
            if array.isEmpty {
                resolver.fulfill("ok")
            }
            else {
                let hexarray = array.map { (contact) -> String in
                    return contact.publicKey
                }
                CPHttpReqHelper.requestSetMuteNotificationBatch(action,
                                                                type: NCProtoChatType.chatTypeGroup,
                                                                related_pub_keys: hexarray)  { (r, msg, rsp) in
                                                                    if let code = rsp?.result,
                                                                        code == ChatErrorCode.OK.rawValue {
                                                                        resolver.fulfill("ok")
                                                                    }
                                                                    else {
                                                                        resolver.reject(NSError(domain: "error", code: 2, userInfo: nil))
                                                                    }
                }
            }
        }
        return _promise
    }
    
    //MARK:- tips
    fileprivate func popConfirmAlert() -> Promise<String> {
        let _promise = Promise<String> { ( resolver :Resolver<String>) in
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                alert.titleLabel?.text = "Confirm".localized()
                alert.msgLabel?.text = self.bTipL?.text
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Confirm".localized(), for: .normal)
                Router.showAlert(view: alert)
                
                alert.okBlock = {
                    resolver.fulfill("ok")
                }
                alert.cancelBlock = {
                    resolver.reject(NSError(domain: "error", code: 1, userInfo: nil))
                }
            }
            else {
                resolver.reject(NSError(domain: "error", code: 1, userInfo: nil))
            }
        }
        return _promise
    }
    
    //MARK:- Table
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 10
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = self.view.backgroundColor
    }
}
