  
  
  
  
  
  
  

import Foundation
import AudioToolbox

class RoomStatus {
    
    static var inChatRoom: Bool? = false
    static var appInBackground: Bool = false
    
      
    static var sessionId: Int?
    static var toPublicKey: String?
    static var remark: String?
    
      
    static var createdGroup: CPContact? = nil
}

class GroupRoomService: RoomStatus {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    var relateSession: CPSession?
    
      
    var chatContact: StoreObservable<CPContact>? {
        didSet {
            self.loadGroupMembers()
            if relateSession == nil {
                loadSession()
            }
        }
    }
    
      
    let isMeGroupMaster: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let isMeGroupManager:BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    let myGroupAlias:BehaviorRelay<String> = BehaviorRelay(value: "")
    
    let groupSummaryMember:BehaviorRelay<[CPGroupMember]> = BehaviorRelay(value: [])
    
    var groupMasterPubkey: String? {
        didSet {
            calMeRole()
        }
    }
    
      
    
    private func loadSession() {
        let sid = Int(self.chatContact?.value.sessionId ?? 0)
        CPSessionHelper.getOneSession(byId: sid) { [weak self] (r, msg, session) in
            self?.relateSession = session
        }
    }
    
    func requestGroupInfo() {
        let pubkey = self.chatContact?.value.publicKey ?? ""
        CPGroupManagerHelper.requestServerGroupInfo(pubkey) { [weak self] (r, msg, data) in
            if r == true, let info = data  {
                let timezone = TimeZone(identifier: "UTC")
                let locale = Locale.current   
                let date = NSDate(string: info.modified_time, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: timezone, locale: locale)
                let diff = (date?.timeIntervalSince1970 ?? 0) * 1000;
                
                self?.groupMasterPubkey = info.owner
                
                let encodeHexNotice = info.notice["content"] as? String  ?? ""
                let modified_time = info.notice["modified_time"] as? String ?? ""
                let publisher = info.notice["publisher"] as? String ?? ""
                
                let notice_date = NSDate.init(string: modified_time, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", timeZone: timezone, locale: locale)
                let notice_diff = notice_date?.timeIntervalSince1970 ?? 0
                
                let inviteType = info.invite_type
                
                self?.chatContact?.change(commit: { (contact) in
                    contact.remark = info.name
                    contact.inviteType = inviteType
                    
                    contact.notice_encrypt_content = encodeHexNotice
                    contact.notice_modified_time = notice_diff
                    contact.notice_publisher = publisher
                })
                
                CPGroupManagerHelper.updateGroupName(info.name, byGroupPubkey: pubkey, callback: nil)
                CPGroupManagerHelper.updateGroupNotice(encodeHexNotice,
                                                       modifyTime: notice_diff,
                                                       publisher: publisher,
                                                       byGroupPubkey: pubkey,
                                                       callback: nil)
                CPGroupManagerHelper.updateGroupInviteType(inviteType, byGroupPubkey: pubkey, callback: nil)
                
                
                let modify = self?.chatContact?.value.modifiedTime ?? 0
                if (modify != Int64(diff)) {
                    CPGroupChatHelper.sendRequestMemberList(inGroupPublickey: pubkey) {[weak self] (response) in
                        let json = JSON(response)
                        if let code = json["code"].int , (code == ChatErrorCode.OK.rawValue) {
                            self?.loadGroupMembers()
                        }
                    }
                }
            }
            else if let info = data {
                  
                if info.resultCode == ChatErrorCode.groupNotExist.rawValue {
                    self?.chatContact?.change(commit: { (contact) in
                        contact.groupProgress = GroupCreateProgress.dissolve
                    })
                    CPGroupManagerHelper.updateGroupProgress(GroupCreateProgress.dissolve, orIpalHash: nil, byPubkey: pubkey, callback: nil)
                }
            }
            
        }
    }
    func loadGroupMembers() {
         let sessionId = self.chatContact?.value.sessionId ?? 0
         CPGroupManagerHelper.getAllMemberList(inGroupSession: Int(sessionId)) { (r, msg, members) in
             if r == true {
                 self.groupAllMember = members
             }
         }
     }
    
      
    
      
    var groupAllMember: [CPGroupMember]? {
        didSet {
            calMeRole()
            calGroupSummaryMember()
            calMyAlias()
        }
    }
    
      
    var groupManagerTeam: [CPGroupMember]? {
        didSet {
            calMeRole()
        }
    }
    
    
      
    
    private func calGroupSummaryMember() {
        let isMaster = isMeGroupMaster.value
        if let allMembers = groupAllMember {
            var canSum: [CPGroupMember]
            if isMaster {
                canSum = Array(allMembers.prefix(8))
            } else {
                canSum = Array(allMembers.prefix(9))
            }
            
            let haved = groupSummaryMember.value
            if haved.count != canSum.count {
                groupSummaryMember.accept(canSum)
            }
            else {
                var diff = false
                var canItem: CPGroupMember
                for (index, hitem) in haved.enumerated() {
                    canItem = canSum[index]
                    if (hitem.hexPubkey != canItem.hexPubkey) ||
                        (hitem.nickName != canItem.nickName){
                        diff = true
                        break
                    }
                }
                if diff {
                    groupSummaryMember.accept(canSum)
                }
            }
            
        }
        
    }
    
    private func calMeRole() {
        let selfPubkey = CPAccountHelper.loginUser()?.publicKey ?? ""
        if let masterPubkey = self.groupMasterPubkey {
            isMeGroupMaster.accept(selfPubkey == masterPubkey)
        }
        else if let allmember = self.groupAllMember {
            var master : CPGroupMember? = nil
            for item in allmember {
                if item.role == .owner {
                    master = item
                    break
                }
            }
            if let m = master {
                self.groupMasterPubkey = m.hexPubkey
            }
        }
    }
    
    private func calMyAlias() {
        let selfPubkey = CPAccountHelper.loginUser()?.publicKey ?? ""
        if let allmember = self.groupAllMember {
            for item in allmember {
                if item.hexPubkey == selfPubkey {
                    self.myGroupAlias.accept(item.nickName)
                    break
                }
            }
        }
    }
}



  
var key_roomstatus = ""
extension UIViewController  {
    var roomService: GroupRoomService? {
        set {
            objc_setAssociatedObject(self, &key_roomstatus, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let n = objc_getAssociatedObject(self, &key_roomstatus) as? GroupRoomService {
                return n
            }
            
            if let stack = self.navigationController?.viewControllers.reversed() {
                for item in stack {
                    if let n = objc_getAssociatedObject(item, &key_roomstatus) as? GroupRoomService {
                        return n
                    }
                }
            }
            
            return nil
        }
    }
}

extension UIView {
    var roomService: GroupRoomService? {
        get {
            return self.viewController?.roomService
        }
    }
}

