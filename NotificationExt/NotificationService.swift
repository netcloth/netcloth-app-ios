//
//  NotificationService.swift
//  NotificationExt
//
//  Created by Grand on 2019/10/7.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        let silence =
        UNNotificationSound(named: UNNotificationSoundName("silence.caf"))
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let userinfo = bestAttemptContent.userInfo
            let message = userinfo["message"]
            var msg_name = "unknown"
            var public_key: String?
            
            
            /*
             ▿ 3 elements
             ▿ 0 : 2 elements
               - key : group_name
               - value : 群1
             ▿ 1 : 2 elements
               - key : msg_name
               - value : netcloth.GroupText
             ▿ 2 : 2 elements
               - key : sender_nick_name
               - value : 代
             */
            var groupName: String?
            var senderNickName: String = ""
            var group_pub_key: String = ""
            
            if let message = message as? NSDictionary {
                msg_name = message["msg_name"] as? String ?? "unknown"
                public_key = message["public_key"] as? String
                //for group
                groupName = message["group_name"] as? String
                senderNickName = message["sender_nick_name"] as? String ?? ""
                group_pub_key = message["group_pub_key"] as? String ?? ""
            }
            else {
                //error type
                contentHandler(bestAttemptContent)
                return;
            }
            
            let title = NSLocalizedString("center_new_msg_in", comment: "")
            var body: String = "[\(NSLocalizedString("Message", comment: ""))]"
            
            if msg_name == "netcloth.Text" {
               body = "[\(NSLocalizedString("Text", comment: ""))]"
            }
            else if msg_name == "netcloth.Audio" {
                body = "[\(NSLocalizedString("Audio", comment: ""))]"
            }
            else if msg_name == "netcloth.Image" {
                body = "[\(NSLocalizedString("Picture", comment: ""))]"
            }
            else if msg_name == "netcloth.GroupText" {
                body = "[\(NSLocalizedString("Text", comment: ""))]"
            }
            else if msg_name == "netcloth.GroupAudio" {
                body = "[\(NSLocalizedString("Audio", comment: ""))]"
            }
            else if msg_name == "netcloth.GroupImage" {
                body = "[\(NSLocalizedString("Picture", comment: ""))]"
            }
            
            bestAttemptContent.title = groupName ?? title
            if senderNickName.count > 0 {
                body = "\(senderNickName): " + body
            }
            
            bestAttemptContent.body = body
            
            //from pub key
            var isInDisturb = false
            if let fromPubkey = public_key {
                isInDisturb = ExtensionShare.noDisturb.isInDisturb(pubkey: fromPubkey)
                if isInDisturb {
                    bestAttemptContent.title = NSLocalizedString("Do not disturb", comment: "")
                    bestAttemptContent.body = " "
                    bestAttemptContent.sound = silence
                }
            }
            
            //group
            if group_pub_key.isEmpty == false {
                isInDisturb = ExtensionShare.noDisturb.isInDisturb(pubkey: group_pub_key)
                if isInDisturb {
                    bestAttemptContent.title = groupName ?? ""
                    bestAttemptContent.body = NSLocalizedString("Do not disturb", comment: "")
                    bestAttemptContent.sound = silence
                }
            }
            
            //badge
            var count = ExtensionShare.unreadStore.getUnreadCount()
            if isInDisturb == false {
                count += 1
                ExtensionShare.unreadStore.setUnreadCount(count)
            }
            let v = max(0, count)
            bestAttemptContent.badge = NSNumber(value: v)
            
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
