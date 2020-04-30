//
//  GroupManageVC.swift
//  chat
//
//  Created by Grand on 2019/12/13.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class GroupManageVC: BaseViewController {
    
    @IBOutlet weak var manageControl: UIControl?
    @IBOutlet weak var manageLabel: UILabel?
    
    @IBOutlet weak var dissolveControl: UIControl?
    
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configEvent()
        handleChange()
    }
    
    
    func configEvent() {
        self.dissolveControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onDissolve()
        }).disposed(by: disbag)
        
        manageControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onSelectManageStyle()
        }).disposed(by: disbag)
        
        self.roomService?.chatContact?.observable.subscribe({ [weak self] (e) in
            self?.handleChange()
        }).disposed(by: disbag)
        
    }
    
    func handleChange() {
        let rec = self.roomService?.chatContact?.value.inviteType ?? CPGroupInviteType.allowAll.rawValue
        if rec == CPGroupInviteType.onlyOwner.rawValue {
            manageLabel?.text = "invite_only_ower".localized()
        }
        else if rec == CPGroupInviteType.needApprove.rawValue {
            manageLabel?.text = "invite_approve_need".localized()
        }
        else {
            manageLabel?.text = "invite_all_allow".localized()
        }
    }
    
    
    //MARK:- Action
    func onSelectManageStyle() {
        _ = showRecieveNoticeAlert().subscribe(onNext: { [weak self] (style) in
            self?.showLoading()
            let groupPrikey = self?.roomService?.chatContact?.value.decodePrivateKey() ?? Data()
            let pubkey = OC_Chat_Plugin_Bridge.hexPublicKey(fromPrivatekey: groupPrikey)
            CPGroupChatHelper.sendGroupUpdate(style, groupPrivateKey: groupPrikey) { (response) in
                self?.dismissLoading()
                let json = JSON(response)
                if let code = json["code"].int ,
                (code == ChatErrorCode.OK.rawValue) {
                    self?.roomService?.chatContact?.change(commit: { (contact) in
                        contact.inviteType = style.rawValue
                    })
                    CPGroupManagerHelper.updateGroupInviteType(style.rawValue, byGroupPubkey: pubkey, callback: nil)
                } else {
                    Toast.show(msg: "System error".localized())
                }
            }
        })
    }
    
    func onDissolve() {
        _ = showPostAlert().subscribe(onNext: { [weak self] (e) in
            guard let prikey = self?.roomService?.chatContact?.value.decodePrivateKey()
                else {
                    return
            }
            let pubkey = OC_Chat_Plugin_Bridge.hexPublicKey(fromPrivatekey: prikey)
            CPGroupChatHelper.sendGroupDismiss(inGroupPrivateKey: prikey) { (response) in
                let json = JSON(response)
                if json["code"].int == 0 {
                    CPGroupManagerHelper.updateGroupProgress(GroupCreateProgress.dissolve, orIpalHash: nil, byPubkey: pubkey, callback: nil)
                    
                    //to room page
                    if let vcs = self?.navigationController?.viewControllers {
                        for v in vcs {
                            if v is GroupRoomVC {
                                self?.navigationController?.popToViewController(v, animated: true)
                                break
                            }
                        }
                    }
                    
                } else {
                    Toast.show(msg: "System error".localized())
                }
            }
        });
    }
    
    //MARK:- Helper
    func showRecieveNoticeAlert() -> Observable<CPGroupInviteType> {
        return Observable.create { [weak self] (observer) -> Disposable in
            
            if let alert = R.loadNib(name: "GroupManageAlert") as? GroupManageAlert {
                //config
                let rec = self?.roomService?.chatContact?.value.inviteType ?? CPGroupInviteType.allowAll.rawValue
                alert.hightlightRecieve(isOnlyAdmin: rec == CPGroupInviteType.onlyOwner.rawValue,
                                        invApproval: rec == CPGroupInviteType.needApprove.rawValue,
                                        everyCan: rec == CPGroupInviteType.allowAll.rawValue)
                
                
                alert.onlyAdminHandle = {
                    observer.onNext(CPGroupInviteType.onlyOwner)
                }
                alert.invApprovalHandle = {
                    observer.onNext(CPGroupInviteType.needApprove)
                }
                alert.everyCanHandle = {
                    observer.onNext(CPGroupInviteType.allowAll)
                }
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }
    
    
    
    
    func showPostAlert() -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            if let alert = R.loadNib(name: "MayEmptyAlertView") as? MayEmptyAlertView {
                //config
                alert.titleLabel?.isHidden = true
                alert.msgLabel?.text = "Dissolve_toast".localized()
                alert.msgLabel?.textColor = UIColor(hexString: Color.black)
                
                alert.cancelButton?.setTitle("Cancel".localized(), for: .normal)
                alert.okButton?.setTitle("Confirm".localized(), for: .normal)
                
                alert.cancelBlock = {
                    observer.onCompleted()
                }
                alert.okBlock = {
                    observer.onNext(())
                    observer.onCompleted()
                }
                Router.showAlert(view: alert)
            }
            return Disposables.create()
        }
    }
    
}
