







import UIKit
import FCFileManager
import PromiseKit


public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG

    var idx = items.startIndex
    let endIdx = items.endIndex

    repeat {
        Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        idx += 1
    }
    while idx < endIdx

    #endif
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        Bundle.swizzleImp()
        let cul = Bundle.currentLanguage()
        if cul.isManual {
            var lan = CustomLanguage(rawValue: cul.language ?? "en") ?? CustomLanguage.en
            Bundle.setCustomLanguage(lan)
        } else {
            Bundle.recoveryToSystem()
        }
        
        Router.rootWindow = window
        
        PPNotificationCenter.shared.registerNotice()
        
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        } else {
            
        }
        
        
        ThirdPartTool.setup()
        
        
        #if DEBUG
        TestSwiftObj.testTransfer()
        #endif
        
        return true
    }
        
    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        RoomStatus.appInBackground = true
        PPNotificationCenter.shared.reCalBadge()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        RoomStatus.appInBackground = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PPNotificationCenter.shared.resetZeroBadge()
    }

    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("deviceToken error \(error)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var deviceTokenString = String()
        let bytes = [UInt8](deviceToken)
        for item in bytes {
            deviceTokenString += String(format:"%02x", item&0x000000FF)
        }
        
        NSLog("deviceToken: %@", deviceTokenString)
        print("deviceToken：\(deviceTokenString)")
        CPAccountHelper.configDeviceToken(deviceTokenString)
    }
}

