  
  
  
  
  
  
  
import UserNotifications
import Foundation

class PPNotificationCenter :NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = PPNotificationCenter()
    
    let dealInForegroundIdenty: String = "dealInForegroundIdenty"
    
    func registerNotice() {
        
        let register = {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                
                if settings.authorizationStatus == .notDetermined {
                    center.requestAuthorization(options: [.badge,.sound,.alert], completionHandler: { (grand, err) in
                        if grand {
                            register()
                        }
                    })
                }
                else {
                    register()
                }
            }
        }
    }
    
    func resetZeroBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func reCalBadge() {
        let count = ExtensionShare.unreadStore.getUnreadCount()
        UIApplication.shared.applicationIconBadgeNumber =  count
    }
    
    
    func sendALocalNotice (msg:CPMessage? = nil) {
        var block =
        {
            let content = UNMutableNotificationContent()
            content.title = msg?.senderRemark.getSmallRemark() ?? NSLocalizedString("center_new_msg_in", comment: "")
            
            if msg?.msgType == .audio {
                content.body = "[\(NSLocalizedString("Audio", comment: ""))]"
            }
            else if (msg?.msgType == .text) {
                if let c = msg?.msgDecodeContent() as? String {
                    content.body = c
                }
            }
            else {
                content.body = NSLocalizedString("center_new_msg_in", comment: "")
            }
            
            
            content.badge = 1
            if Config.Settings.bellable == true {
                content.sound = .default
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            
              
            let request = UNNotificationRequest(identifier: "msgId\(msg?.msgId)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                print(error)
            }
        }
        
        DispatchQueue.global().async {
            msg?.msgDecodeContent()
            
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    
    func sendALocalNotifyMsg(msg: String) -> Void {
        let block =
        {
            let content = UNMutableNotificationContent()
            content.title = msg
            let count = ExtensionShare.unreadStore.getUnreadCount()
            content.badge =  NSNumber(value:  count + 1)
            if Config.Settings.bellable == true {
                content.sound = .default
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
              
            let request = UNNotificationRequest(identifier: self.dealInForegroundIdenty, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            block()
        }
    }
}



extension PPNotificationCenter {
      
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if notification.request.identifier == dealInForegroundIdenty {
            completionHandler([.alert, .sound, .badge])
        }
        
    }
    
}

