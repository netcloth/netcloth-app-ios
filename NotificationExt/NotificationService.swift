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
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let userinfo = bestAttemptContent.userInfo
            let message = userinfo["message"]
            var msg_name = "unknown"
            
            if let message = message as? NSDictionary {
                msg_name = message["msg_name"] as? String ?? "unknown"
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
            
            bestAttemptContent.title = title
            bestAttemptContent.body = body
            
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
