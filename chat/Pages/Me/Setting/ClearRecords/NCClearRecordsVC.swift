//
//  NCClearRecordsVC.swift
//  chat
//
//  Created by Grand on 2019/11/19.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import PromiseKit

let KClearWhenLogout = "KClearWhenLogout"

class NCClearRecordsVC: BaseTableViewController {
    
    @IBOutlet weak var clearSwitch: UISwitch?
    let disbag = DisposeBag()
    @IBOutlet weak var clearRecordL: UILabel?
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            // Fallback on earlier versions
        }
        super.viewDidLoad()
        configUI()
        refreshCells()
        configEvent()
    }
    
    func configUI() {
        clearSwitch?.onTintColor = UIColor(hexString: Color.blue)
        clearSwitch?.tintColor = UIColor(hexString: "#E1E4E9")
        self.tableView.adjustFooter()
    }
    
    func configEvent() {
        
        clearSwitch?.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] (event) in
            let isOn = self?.clearSwitch?.isOn ?? false
            if isOn {
                self?.recordLogoutClear()
            } else {
                self?.deRecordClear()
            }
        }).disposed(by: disbag)
        
        self.tableView.rx.itemSelected.subscribe { [weak self] (event: Event<IndexPath>) in
            let path = event.element
            if path?.row == 1 {
                self?.clearAllChatRecord()
            }
            
        }.disposed(by: disbag)
    }
    
    func recordLogoutClear() {
        self.popRecoredAlert().done { (result) in
            UserSettings.setObject("1", forKey: KClearWhenLogout)
        }
        .catch { error in
            self.clearSwitch?.isOn = false
        }
    }
    
    func deRecordClear() {
        UserSettings.setObject(nil, forKey: KClearWhenLogout)
    }
    
    func clearAllChatRecord() {
        self.popClearNowAlert().done { [weak self] (result) in
            self?.showLoading()
            CPSessionHelper.deleteAllSessionComplete { (r, msg) in
                self?.dismissLoading()
                self?.navigationController?.popToRootViewController(animated: false)
                
                //select home
                if let rootVC = Router.rootVC as? UINavigationController,
                    let baseTabVC = rootVC.topViewController as? GrandTabBarVC {
                    baseTabVC.switchToTab(index: 0)
                }
            }
        }
    }
    
    func refreshCells() {
        if let v =  UserSettings.object(forKey: KClearWhenLogout) as? String, v == "1" {
            clearSwitch?.isOn = true
        } else {
            clearSwitch?.isOn = false
        }
    }
    
    //MARK:- Helper
    func popRecoredAlert() -> Promise<String> {
        let _promise = Promise<String> { ( resolver :Resolver<String>) in
            if let alert = R.loadNib(name: "OneButtonOneMsgAlert") as? OneButtonOneMsgAlert {
                alert.msgLabel?.text = "clear_alert_title".localized()
                alert.okButton?.setTitle("clear_alert_btn_text".localized(), for: .normal)
                alert.okBlock = {
                    resolver.fulfill("ok")
                }
                Router.showAlert(view: alert)
            }
            else {
                resolver.reject(NSError(domain: "error", code: 1, userInfo: nil))
            }
        }
        return _promise
    }
    
    func popClearNowAlert() -> Promise<String> {
        let _promise = Promise<String> { ( resolver :Resolver<String>) in
            if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
                alert.titleLabel?.text = "clear_now_alert_title".localized()
                alert.msgLabel?.text = "clear_now_alert_msg".localized()
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("clear_now_btn_ok_text".localized(), for: .normal)
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
}
