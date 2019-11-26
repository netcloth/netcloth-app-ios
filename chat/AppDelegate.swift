







import UIKit
import FCFileManager


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        let path = FCFileManager.pathForDocumentsDirectory()
        print(path)
        
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
        

        IPALManager.shared.test_for()
        
        return true
    }
        
    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        RoomStatus.appInBackground = true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        RoomStatus.appInBackground = false
        PPNotificationCenter.shared.resetBadge()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        
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

