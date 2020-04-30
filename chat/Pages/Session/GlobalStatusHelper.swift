//
//  GlobalStatusHelper.swift
//  chat
//
//  Created by Grand on 2020/2/10.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

extension String {
    func isAssistHelper() -> CPAssistant? {
        for item in GlobalStatusStore.shared.allAssists {
            if item.pub_key == self {
                return item
            }
        }
        return nil
    }
    
    func isCurNodeAssist() -> CPAssistant? {
        if GlobalStatusStore.shared.curAssist?.pub_key == self {
            return GlobalStatusStore.shared.curAssist
        }
        return nil
    }
}

class GlobalStatusStore: NSObject {
    static let shared = GlobalStatusStore()
    
    //MARK:-  Property
    var curAssist: CPAssistant?
    var allAssists: [CPAssistant] = []
    
    /// recommend group
    var recommendedGroup: [CPRecommendedGroup]?
    var recommendedGroupSession: CPSession?
    var isShowRecommendedGroup:Bool {
        let empty = recommendedGroup?.isEmpty ?? true
        return !empty
    }

    
    //MARK:- Public
    func onLogin() {
        allAssists = []
        curAssist = nil
        recommendedGroup = nil
        recommendedGroupSession = nil
        
        CPContactHelper.update(ContactStatus.assistHelper, whereContactUser: support_account_pubkey, callback: nil)
        
        CPContactHelper.getNormalContacts { (result) in
            let assists  = result.filter { (contact) -> Bool in
                if contact.status == .assistHelper {
                    return true
                }
                return false
            }
            let mapper = assists.map { (contact) -> CPAssistant in
                let toass = CPAssistant()
                toass.pub_key = contact.publicKey
                toass.nick_name = contact.remark
                toass.avatar = contact.avatar
                toass.server_addr = contact.server_addr
                return toass
            }
            self.allAssists = mapper
        }
    }
    
    func onResetIpalNode() {
        self.curAssist = nil
        recommendedGroup = nil
        recommendedGroupSession = nil
    }
    
    func requestServerAssist(complete: (() -> Void)? = nil) {
        curAssist = nil
        _ = fetchAssistList().subscribe(onNext: { [weak self] (assist) in
            self?.curAssist = assist
        }, onCompleted: { [weak self] in
            complete?()
            if let a = self?.curAssist {
                let pubkey = a.pub_key
                CPContactHelper.addAssistHelperAssist(a,callback: { (r, msg, contact) in
                    if r == false {
                        return
                    }
                    CPContactHelper.removeUser(fromBlacklist: pubkey, callback: nil)
                    CPContactHelper.removeUser(fromDoNotDisturb: pubkey) { (r, msg) in
                        if r {
                            ExtensionShare.noDisturb.removeDisturb(pubkey: pubkey)
                        }
                    }
                })
                self?.saveAssist(a)
            }
        })
    }
    
    func onRequestRecommendedGroup(complete: (() -> Void)? = nil) {
        self.requestRecommended().then({(result) -> Promise<CPSession> in
            GlobalStatusStore.shared.recommendedGroup = result
            self.configRecommendedGroupSession(count: result.count)
            return self.getRecommendedSession()
        }).done { (result) in
            GlobalStatusStore.shared.recommendedGroupSession = result
        }.catch { (error) in
        }.finally {
            complete?()
        }
    }
    
    //MARK:- Helper
    
    fileprivate func configRecommendedGroupSession(count: Int) {
        let first = UserSettings.object(forKey: Config.firstAccountInstall)
        if first as? String == "1" {
        } else {
            UserSettings.setObject("1", forKey: Config.firstAccountInstall)
            CPSessionHelper.fakeUpdateRecommendedGroupSessionCount(count)
        }
    }
    
    fileprivate func requestRecommended() -> Promise<[CPRecommendedGroup]> {
        let alert =  Promise<[CPRecommendedGroup]> { (resolver) in
            CPSessionHelper.requestRecommendedGroup { (r, msg, recommend) in
                if let rg = recommend, rg.count > 0 {
                    resolver.fulfill(rg)
                }
                else {
                    let error = NSError(domain: "recommended", code: 1, userInfo: nil)
                    resolver.reject(error)
                }
            }
        }
        return alert
    }
    
    func getRecommendedSession() -> Promise<CPSession> {
        let alert =  Promise<CPSession> { (resolver) in
            CPSessionHelper.getOneSession(byId: -1) { (r, msg, sesssion) in
                if let s = sesssion {
                    resolver.fulfill(s)
                }
                else {
                    let error = NSError(domain: "recommended", code: 2, userInfo: nil)
                    resolver.reject(error)
                }
            }
        }
        return alert
    }
    
    fileprivate func saveAssist(_ assist: CPAssistant) {
        self.allAssists.removeAll {return $0.pub_key == assist.pub_key}
        self.allAssists.append(assist)
    }
    
    fileprivate func fetchAssistList() -> Observable<CPAssistant> {
        return Observable.create { (observer) -> Disposable in
            let path = CPNetURL.getAssistantList
            
            let rspback = { (data: Data?, complete: Bool)in
                if let d = data {
                    let json = JSON(d)
                    if let customer = json["customer"].dictionaryObject,
                        let assist = CPAssistant.model(withJSON: customer) {
                        observer.onNext(assist)
                    }
                    if complete {
                        observer.onCompleted()
                    }
                }
            }
            
            CPNetWork.getCacheDataUrl(path: path, cacheRsp: { (data) in
                rspback(data,false)
            }, fetchComplete: { (r, data) in
                rspback(data,true)
            })
            
            return Disposables.create()
        }
    }
}
