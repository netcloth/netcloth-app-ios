//
//  SessionCardsVC.swift
//  chat
//
//  Created by Grand on 2019/11/20.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import PromiseKit

class SessionCardsVC: BaseViewController {
    
    private var session: CPSession?
    private var contact: CPContact?
    var contactPublicKey: String?
    
    //1 from chat,
    var sourceTag: Int? = 0
    
    @IBOutlet weak var smallRemark: UILabel?
    @IBOutlet weak var remark: UILabel?
    
    @IBOutlet weak var markTopSwitch: UISwitch?
    @IBOutlet weak var doNotDisturb: UISwitch?
    @IBOutlet weak var addBlackSwitch: UISwitch?
    
    @IBOutlet weak var clearChatRecord: UIControl?
    
    let disbag = DisposeBag()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        fetchData()
        configEvent()
    }
    
    func fetchData() {
        guard let pk = self.contactPublicKey else {
            return
        }
        findContactByPubkey(pk).then { (contact:CPContact) -> Promise<CPSession> in
            self.contact = contact
            return self.findSessionBySessionId(Int(contact.sessionId))
        }.done { (session:CPSession) in
            self.session = session
        }.catch { (error) in
            
        }.finally {
            self.fillData()
        }
    }
    
    func fillData() {
        smallRemark?.text = contact?.remark.getSmallRemark()
        remark?.text = contact?.remark
        
        let color = contact?.publicKey.randomColor() ?? RelateDefaultColor
        smallRemark?.backgroundColor = UIColor(hexString: color)
        
        markTopSwitch?.isOn = (session?.topMark == 1)
        doNotDisturb?.isOn = (contact?.isDoNotDisturb == true)
        addBlackSwitch?.isOn =  (contact?.isBlack == true)
        
    }
    
    //MARK:- Config
    func configUI() {
        
        markTopSwitch?.onTintColor = UIColor(hexString: Color.blue)
        markTopSwitch?.tintColor = UIColor(hexString: "#E1E4E9")
        
        doNotDisturb?.onTintColor = UIColor(hexString: Color.blue)
        doNotDisturb?.tintColor = UIColor(hexString: "#E1E4E9")
        
        addBlackSwitch?.onTintColor = UIColor(hexString: Color.blue)
        addBlackSwitch?.tintColor = UIColor(hexString: "#E1E4E9")
    }
    
    func configEvent() {
        
        //mark top
        markTopSwitch?.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] (event) in
            let sessionId = Int(self?.contact?.sessionId ?? 0)
            if self?.markTopSwitch?.isOn == true {
                CPSessionHelper.markTop(ofSession: sessionId, complete: nil)
            } else {
                CPSessionHelper.unTop(ofSession: sessionId, complete: nil)
            }
        }).disposed(by: disbag)
        
        
        //doNotDisturb
        doNotDisturb?.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] (event) in
            let pubkey = self?.contactPublicKey ?? ""
            if self?.doNotDisturb?.isOn == true {
                InnerHelper.addToMute(hexPubkey: pubkey,
                                      chatType: NCProtoChatType.chatTypeSingle,
                                      target: self?.doNotDisturb)
                
            } else {
                InnerHelper.removeMute(hexPubkey: pubkey,
                                       chatType: NCProtoChatType.chatTypeSingle,
                                       target: self?.doNotDisturb)
            }
        }).disposed(by: disbag)
        
        
        //add black
        addBlackSwitch?.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] (event) in
            if self?.addBlackSwitch?.isOn == true {
                self?.onActionAddBlack()
            } else {
                self?.onActionDeleteFromBlack()
            }
        }).disposed(by: disbag)
        
        
        //clear
        clearChatRecord?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] (event) in
            let sessionId = Int(self?.contact?.sessionId ?? 0)
            self?.onActionClearChatRecord(sessionId: sessionId)
        }).disposed(by: disbag)
        
        NotificationCenter.default.rx.notification( NoticeNameKey.contactRemarkChange.noticeName).subscribe(onNext: { [weak self] (notice) in
            if let contact = notice.object as? CPContact {
                self?.onHandleRemarkChange(contact: contact)
            }
        }).disposed(by: disbag)
    }
    
    //MARK:- Action
    func onHandleRemarkChange(contact: CPContact) {
        if contact.publicKey != contactPublicKey {
            return
        }
        self.contact?.remark = contact.remark
        self.fillData()
    }
    
    func onActionClearChatRecord(sessionId: Int) {
        
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView {
            alert.titleLabel?.text = "Session_W_Title".localized()
            alert.msgLabel?.text = "Session_W_Msg".localized()
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            let pubkey = self.contactPublicKey ?? ""
            
            alert.okBlock = {
                
                CPSessionHelper.clearSessionChats(in: sessionId, with: SessionType.P2P) { [weak self] (r, msg) in
                    if r == true {
                        self?.navigationController?.popViewController(animated: true)
                        //notify
                        NotificationCenter.post(name: .chatRecordDeletes, object: pubkey)
                    } else {
                        Toast.show(msg: "System error".localized())
                    }
                }
            }
        }
    }
    
    func onActionAddBlack() {
        
        if let alert = R.loadNib(name: "NormalAlertView") as? NormalAlertView,
            let contact = self.contact {
            alert.titleLabel?.text = "Blacklist".localized()
            let msg = "Blacklist_msg".localized().replacingOccurrences(of: "#remark#", with: contact.remark)
            alert.msgLabel?.text = msg
            
            alert.cancelButton?.setTitle("Back".localized(), for: .normal)
            alert.okButton?.setTitle("Confirm".localized(), for: .normal)
            Router.showAlert(view: alert)
            
            alert.okBlock = { [weak self] in
                InnerHelper.addToBlack(hexPubkey: contact.publicKey, target: self?.addBlackSwitch)
            }
            alert.cancelBlock = { [weak self] in
                self?.addBlackSwitch?.isOn = false
            }
        }
    }
    
    func onActionDeleteFromBlack() {
        if let contact = self.contact {
            InnerHelper.removeBlack(hexPubkey: contact.publicKey,
                                    target: self.addBlackSwitch)
        }
    }
    
    @IBAction func onToContactInfo() {
        if let _ = contactPublicKey?.isAssistHelper() {
            return
        }
        if let vc = R.loadSB(name: "ContactCard", iden: "ContactCardVC") as? ContactCardVC {
            vc.contactPublicKey = contactPublicKey
            vc.sourceTag = 1
            Router.pushViewController(vc: vc)
        }
    }
}

//MARK:- Helper
extension SessionCardsVC {
    func findContactByPubkey(_ pubkey:String) -> Promise<CPContact> {
        let _promise = Promise<CPContact> { (resolver) in
            CPContactHelper.getOneContact(byPubkey: pubkey) {(r, msg, tmpContact) in
                if let tp = tmpContact {
                    resolver.fulfill(tp)
                } else {
                    resolver.reject(NSError(domain: "error", code: 1, userInfo: nil))
                }
            }
        }
        return _promise
    }
    
    func findSessionBySessionId(_ sessionId:Int) -> Promise<CPSession> {
        let _promise = Promise<CPSession> { (resolver) in
            CPSessionHelper.getOneSession(byId: sessionId) { (r, msg, tmpSession) in
                if let tp = tmpSession {
                    resolver.fulfill(tp)
                } else {
                    resolver.reject(NSError(domain: "error", code: 2, userInfo: nil))
                }
            }
        }
        return _promise
    }
}


extension Promise {
    static func create(resolver body: (Resolver<T>) throws -> Void) -> Promise<T> {
        
        return Promise<T> { (resolver) in
            
            do {
                try body(resolver)
            } catch {
                resolver.reject(error)
            }
        }
    }
}
