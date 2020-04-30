//
//  InnerHelper.swift
//  chat
//
//  Created by Grand on 2019/9/24.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class InnerHelper: NSObject {
    
    static func converStringToPinYin(inString: String) -> String {
        let title = inString as NSString
        let letters = PinyinHelper.toHanyuPinyinStringArray(withChar: title.character(at: 0)) as? [String]
        let firstCharacter = String(letters?.first?.prefix(1) ?? (title as String).prefix(1))
        
        let index = firstCharacter.isEnglish() ? firstCharacter.uppercased() : "#"
        return index
    }
    
    
    //MARK:-  二维码辅助
    @available(*, deprecated, message: "See `v2_toString(contact:)`")
    static func v1_toString(contact: CPContact) -> String?  {
        return v1_toContactString(pubkey: contact.publicKey, alias: contact.remark)
    }
    
    @available(*, deprecated, message: "See `v2_toString(contact:)`")
    static func v1_toContactString(pubkey: String, alias: String) -> String? {
        var dic:NSMutableDictionary = NSMutableDictionary()
        dic["netcloth"] = "contact"
        dic["version"] = 1
        dic["alias"] = alias
        dic["address"] = pubkey
        return dic.modelToJSONString()
    }
    
    static func v2_toString(contact: CPContact) -> String? {
        return v2_toContactString(pubkey: contact.publicKey,
                                  alias: contact.remark,
                                  type: contact.sessionType == SessionType.group ? 1 : 0)
    }
    
    /*
     https://chat-app.netcloth.org?publicKey=0304d54ad1f6fab98b9b1842c0b08d53cafb8dc626b4c7c92be9a3f30af20ce856&alias=iii&type=0
     */
    static func v2_toContactString(pubkey: String, alias: String, type: Int = 0) -> String? {
        let compressHexPublickey = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: pubkey) ?? ""
        return "https://chat-app.netcloth.org?publicKey=\(compressHexPublickey)&alias=\(alias)&type=\(type)"
    }
    
    static func v2_toTransferString(addr: String, type: Int = 3, chainId: Int = 0) -> String? {
        return  "https://chat-app.netcloth.org?address=\(addr)&type=\(type)&chainID=\(chainId)"
    }
    
    //MARK: - 解码
    fileprivate static func find(array:[URLQueryItem], valueOfKey para: String) -> String? {
        for item in array {
            if item.name == para {
                return item.value
            }
        }
        return nil
    }
    
    enum DecodeQRResult {
        case contact(publicKey: String, alias:String, type:SessionType)
        case recieveCoin(address: String, type: String, chainID: String)
        
        case url(str: String)
        case notFound(origin: Any)
    }
    
    static func v3_decodeScanInput(str: Any) -> DecodeQRResult {
        /// transfer
        var r = v3_decodeTransfer(str: str)
        guard case .notFound(_) = r else {
            return r
        }
        /// contact
        r = v3_decodeContact(str: str)
        guard case .notFound(_) = r else {
            return r
        }
        
        return .notFound(origin: str)
    }
    
    fileprivate static func v3_decodeTransfer(str: Any) -> DecodeQRResult {
        if let input = str as? String, input.hasPrefix("http")
        {
            guard
                let address = input.getValueOf(parameter: "address"),
                let type = input.getValueOf(parameter: "type"),
                let chainID = input.getValueOf(parameter: "chainID"),
                (type == "3"),
                (chainID == "0")
                else {
                    return .notFound(origin: str)
            }
            return .recieveCoin(address: address,
                                type: type,
                                chainID: chainID)
        }
        return .notFound(origin: str)
    }
    fileprivate static func v3_decodeContact(str: Any) -> DecodeQRResult {
        if let input = str as? String, input.hasPrefix("http")
        {
            guard
                 let publicKey = input.getValueOf(parameter: "publicKey"),
                 let alias = input.getValueOf(parameter: "alias"),
                 let type = input.getValueOf(parameter: "type"),
                (type == "1" || type == "0")
            else {
                    return .notFound(origin: str)
            }
            return .contact(publicKey: publicKey,
                            alias: alias,
                            type: type == "1" ? SessionType.group : SessionType.P2P )
        }
        return .notFound(origin: str)
    }
    
    //MARK:- legacy
    
    static func v2_decodeScanInput(str: Any, wantType: String) -> (valid: Bool, data: Any?, minorData: Any?, type: SessionType) {
        
        /// contact
        if let input = str as? String, input.hasPrefix("http") {
            let publicKey = input.getValueOf(parameter: "publicKey")
            let alias = input.getValueOf(parameter: "alias")
            let type = input.getValueOf(parameter: "type")
            
            guard let pk = publicKey,
                let mark = alias,
                let t = type,
                let unCompressPubKey = OC_Chat_Plugin_Bridge.unCompressedHexStrPubkey(ofCompressHexPubkey: pk) else {
                    return (false, nil, nil, .P2P)
            }
            return (true,unCompressPubKey, mark, t == "1" ? SessionType.group : .P2P )
        }
                
        let v1 =  v1_decodeJson(str: str, wantType: wantType)
        return (v1.valid, v1.data, v1.minorData, SessionType.P2P)
    }
    
    static func v1_decodeJson(str: Any, wantType: String) -> (valid: Bool, data: Any?, minorData: Any?) {
        guard let _str = str as? String else {
            return (false, nil, nil)
        }
        
        if let dic =  _str.jsonValueDecoded() as? NSDictionary {
            if let _want = dic.object(forKey: "netcloth") as? String,
                _want == wantType {
                //ok json
                if wantType == "contact" {
                    let _d = dic["address"]
                    let _m = dic["alias"]
                    return (true, _d, _m)
                } else {
                    //unknown
                    return (false, nil, nil)
                }
                
            } else {
                //error
                return (false, nil, nil)
            }
        }
        else {
            //origin json
            return (true, _str, nil)
        }
    }
    
    //MARK:- 解析 群通知
    static func decode(notice: CPGroupNotify) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            DispatchQueue.global().async {
                let data = notice.approveNotify
                let approve = try? NCProtoGroupJoinApproveNotify.parse(from: data)
                if let joinMsg = approve?.joinMsg {
                    //inviterNickName for next
                    notice.join_msg = joinMsg
                    if let realJoin = try? NCProtoGroupJoin.parse(from: joinMsg.data_p) {
                        notice.decodeJoinRequest = realJoin
                        notice.decodeRequestReason()
                        
                        notice.manualDecode = true
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        observer.onCompleted()
                    }
                } else {
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    //MARK:- 解析 消息
    /* 注意是在 异步线程回调
     */
    static func decode(message: CPMessage) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            DispatchQueue.global().async {
                message.msgDecodeContent()
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func decodeOnlyText(message: CPMessage) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            DispatchQueue.global().async {
                message.msgDecodeContent_onlyTextType()
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}

extension InnerHelper {
    static func showOnlyGroupAdminInviteTip() {
        if let alert = R.loadNib(name: "OneButtonOneMsgAlert") as? OneButtonOneMsgAlert {
            var tips = "Only_Group_Admin_Invite_tip".localized()
            alert.msgLabel?.text = tips
            alert.msgLabel?.textColor = UIColor(hexString: Color.black)
            alert.msgLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
            alert.okButton?.setTitle("clear_alert_btn_text".localized(), for: .normal)
            Router.showAlert(view: alert)
        }
    }
    
    static func filterCIPALs(list:[IPALNode]) -> [IPALNode] {
        let chatEnters = list.filter({ (item:IPALNode) -> Bool in
            
            #if DEBUG
            
            /// Debug direct
            if item.cIpalEnd() != nil  {
                return true
            }
            
            #else
            
            /// 可切换
            if let obj = UserDefaults.standard.object(forKey: "CusDeb") as? String, obj == "cd" {
                if item.cIpalEnd() != nil  {
                    return true
                }
            }
            else {
                if item.cIpalEnd() != nil,
                    item.details?.starts(with: "test") == false  {
                    return true
                }
            }
            
            #endif
            
            return false
        })
        return chatEnters
    }
    
    static func filterAIPALs(list:[IPALNode]) -> [IPALNode] {
        let chatEnters = list.filter({ (item:IPALNode) -> Bool in
            if let obj = UserDefaults.standard.object(forKey: "CusDeb") as? String, obj == "cd" {
                if item.aIpal() != nil  {
                    return true
                }
            }
            else {
                if item.aIpal() != nil,
                    item.details?.starts(with: "test") == false  {
                    return true
                }
            }
            return false
        })
        return chatEnters
    }
    
}

extension InnerHelper {
    /// Add Black
    static func addToBlack(hexPubkey: String, target:UISwitch?) {
        CPContactHelper.addUser(toBlacklist: hexPubkey) {(r, msg) in
            if r == false {
                Toast.show(msg: msg)
                target?.isOn = false
            }
        }

        
        //upload
        if Config.Settings.muteBlackAble == false {
            target?.viewController?.showLoading()
            CPHttpReqHelper.requestSetBlack(NCProtoActionType.actionTypeAdd,
                                            releated_pub_key: hexPubkey) { (r, msg, rsp) in
                                                target?.viewController?.dismissLoading()
                                                if let code = rsp?.result,
                                                    code == ChatErrorCode.OK.rawValue {
                                                } else {
                                                    Toast.show(msg: "System error".localized())
                                                    target?.isOn = false
                                                }
                                                
            }
        }
    }
    
    static func removeBlack(hexPubkey: String, target:UISwitch?) {
        CPContactHelper.removeUser(fromBlacklist: hexPubkey) { (r, msg) in
            if r == false {
                Toast.show(msg: msg)
                target?.isOn = true
            }
        }
        
        //upload
        if Config.Settings.muteBlackAble == false {
            target?.viewController?.showLoading()
            CPHttpReqHelper.requestSetBlack(NCProtoActionType.actionTypeDelete,
                                            releated_pub_key: hexPubkey) { (r, msg, rsp) in
                                                target?.viewController?.dismissLoading()
                                                if let code = rsp?.result,
                                                    code == ChatErrorCode.OK.rawValue {
                                                } else {
                                                    Toast.show(msg: "System error".localized())
                                                    target?.isOn = true
                                                }
                                                
            }
        }
    }
    

    /// Mute
    static func addToMute(hexPubkey: String,
                          chatType:NCProtoChatType,
                          target:UIView?,
                          complete:((Bool) -> Void)? = nil) {
       
        CPContactHelper.addUser(toDoNotDisturb: hexPubkey) { (r, msg) in
            if r {
                ExtensionShare.noDisturb.addToDisturb(pubkey: hexPubkey)
            }
            else {
                Toast.show(msg: "System error".localized())
                if let t = target as? UISwitch {
                    t.isOn = false
                }
            }
            
            if Config.Settings.muteBlackAble == true {
                complete?(r)
            }
        }
        
        //upload
        if Config.Settings.muteBlackAble == false {
            target?.viewController?.showLoading()
            CPHttpReqHelper.requestSetMuteNotification(NCProtoActionType.actionTypeAdd,
                                                       type: chatType,
                                                       releated_pub_key: hexPubkey)  { (r, msg, rsp) in
                                                target?.viewController?.dismissLoading()
                                                if let code = rsp?.result,
                                                    code == ChatErrorCode.OK.rawValue {
                                                    complete?(true)
                                                } else {
                                                    Toast.show(msg: "System error".localized())
                                                    if let t = target as? UISwitch {
                                                        t.isOn = false
                                                    }
                                                    complete?(false)
                                                }
                                                
            }
        }
    }
    
    static func removeMute(hexPubkey: String,
                           chatType:NCProtoChatType,
                           target:UIView?,
                           complete:((Bool) -> Void)? = nil) {
        
        CPContactHelper.removeUser(fromDoNotDisturb: hexPubkey) { (r, msg) in
            if r {
                ExtensionShare.noDisturb.removeDisturb(pubkey: hexPubkey)
            }
            else {
                Toast.show(msg: msg)
                if let t = target as? UISwitch {
                    t.isOn = true
                }
            }
            if Config.Settings.muteBlackAble == true {
                complete?(r)
            }
        }
        
        //upload
        if Config.Settings.muteBlackAble == false {
            target?.viewController?.showLoading()
            CPHttpReqHelper.requestSetMuteNotification(NCProtoActionType.actionTypeDelete, type: chatType, releated_pub_key: hexPubkey) { (r, msg, rsp) in
                target?.viewController?.dismissLoading()
                if let code = rsp?.result,
                    code == ChatErrorCode.OK.rawValue {
                    complete?(true)
                } else {
                    Toast.show(msg: "System error".localized())
                    if let t = target as? UISwitch {
                        t.isOn = true
                    }
                    complete?(false)
                }
            }
        }
    }
}


extension InnerHelper {
    
    /// for jump
    static func handleDecodeContact(vc: WCQRCodeVC?, result: DecodeQRResult) -> Bool
    {
        guard case .contact(let publicKey, let alias, let type) = result else {
            return false
        }
        if type == SessionType.P2P {
            //to add contact
            let iden = R.className(of: ContactAddVC.self) ?? ""
            if let addVc = R.loadSB(name: "Contact", iden: iden) as? ContactAddVC {
                addVc.wantAddPublicKey = publicKey
                addVc.wantRemark =  alias
                Router.pushViewController(vc: addVc)
            }
            
            //remove WCQRCodeVC
            if let vc = vc {
                withUnsafeMutablePointer(to: &vc.navigationController!.viewControllers, { (v) in
                    v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
                })
            }
        }
        else if type == SessionType.group {
            //to detail
            if let vc = R.loadSB(name: "GroupInviteDetailVC", iden: "GroupInviteDetailVC") as?  GroupInviteDetailVC {
                vc.qr_groupPublickKey = publicKey
                Router.pushViewController(vc: vc)
            }
            //remove WCQRCodeVC
            if let vc = vc {
                withUnsafeMutablePointer(to: &vc.navigationController!.viewControllers, { (v) in
                    v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
                })
            }
        }
        return true
    }
    
    /// for jump
    static func handleDecodeRecieveCoin(vc: WCQRCodeVC?, result: DecodeQRResult) -> Bool
    {
        guard case .recieveCoin(let address, let type, let chainID) = result else {
            return false
        }
        
        if let vc = R.loadSB(name: "TokenTransferVC", iden: "TokenTransferVC") as? TokenTransferVC {
            let wallet = NCUserCenter.shared?.walletDataStore.value.walletOfChainId(Int(chainID)!)
            vc.token = wallet?.assetTokens[safe: 0]
            vc.wantAddr = address
            Router.pushViewController(vc: vc)
        }
        
        //remove WCQRCodeVC
        if let vc = vc {
            withUnsafeMutablePointer(to: &vc.navigationController!.viewControllers, { (v) in
                v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
            })
        }
        return true
    }
}

