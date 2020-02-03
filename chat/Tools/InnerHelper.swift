  
  
  
  
  
  
  

import UIKit

class InnerHelper: NSObject {
    
    static func converStringToPinYin(inString: String) -> String {
        let title = inString as NSString
        let letters = PinyinHelper.toHanyuPinyinStringArray(withChar: title.character(at: 0)) as? [String]
        let firstCharacter = String(letters?.first?.prefix(1) ?? (title as String).prefix(1))
        
        let index = firstCharacter.isEnglish() ? firstCharacter.uppercased() : "#"
        return index
    }
    
    
      
    static func v1_toString(contact: CPContact) -> String? {
        return v1_toContactString(pubkey: contact.publicKey, alias: contact.remark)
    }
    
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
     https:  
     */
    static func v2_toContactString(pubkey: String, alias: String, type: Int = 0) -> String? {
        let compressHexPublickey = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: pubkey) ?? ""
        return "https:  
    }
    
    
      
    static func find(array:[URLQueryItem], valueOfKey para: String) -> String? {
        for item in array {
            if item.name == para {
                return item.value
            }
        }
        return nil
    }
        
    static func v2_decodeScanInput(str: Any, wantType: String) -> (valid: Bool, data: Any?, minorData: Any?, type: SessionType) {
        
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
                  
                if wantType == "contact" {
                    let _d = dic["address"]
                    let _m = dic["alias"]
                    return (true, _d, _m)
                } else {
                      
                    return (false, nil, nil)
                }
                
            } else {
                  
                return (false, nil, nil)
            }
        }
        else {
              
            return (true, _str, nil)
        }
    }
    
      
    static func decode(notice: CPGroupNotify) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            DispatchQueue.global().async {
                let data = notice.approveNotify
                let approve = try? NCProtoGroupJoinApproveNotify.parse(from: data)
                if let joinMsg = approve?.joinMsg {
                      
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
            alert.msgLabel?.textColor = UIColor(hexString: "#303133")
            alert.msgLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
            alert.okButton?.setTitle("clear_alert_btn_text".localized(), for: .normal)
            Router.showAlert(view: alert)
        }
    }
}

extension String {
    
    func getValueOf(parameter:String) -> String? {
        let query = self.components(separatedBy: "?").last
        let items = query?.components(separatedBy: "&")
        if let array = items {
            for kv in array {
                if kv.starts(with: parameter) {
                    let k_v = kv.components(separatedBy: "=")
                    return k_v.last
                }
            }
        }
        return nil
    }
}


extension UIViewController {
    
      
    open func setTitleImage(_ title: String,
                             image: UIImage,
                             color: UIColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1),
                             font: UIFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)) -> UIView
    {
        
        let cv = UIView()
        var stackV = UIStackView()
        cv.addSubview(stackV)
        
        stackV.axis = .horizontal
        stackV.distribution = .fill
        stackV.alignment = .center
        stackV.spacing = 10
        
        let label = UILabel()
        label.text = title
        label.font = font
        label.textColor = color
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
        stackV.addArrangedSubview(label)
        
        let imageV = UIImageView(image: image)
        imageV.setContentHuggingPriority(.required, for: .horizontal)
        imageV.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stackV.addArrangedSubview(imageV)
        
        stackV.snp.makeConstraints { (maker) in
            maker.center.equalTo(cv)
            maker.height.equalTo(30)
            maker.leading.greaterThanOrEqualToSuperview()
            maker.trailing.lessThanOrEqualToSuperview()
        }
        
        self.navigationItem.titleView = cv
        return cv
    }
    
}
