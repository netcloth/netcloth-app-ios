//
//  AppDelegate.swift
//  chat
//
//  Created by Grand on 2019/7/19.
//  Copyright © 2019 netcloth. All rights reserved.
//

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
        
        //language setting
        Bundle.swizzleImp()
        let cul = Bundle.currentLanguage()
        if cul.isManual {
            var lan = CustomLanguage(rawValue: cul.language ?? "en") ?? CustomLanguage.en
            Bundle.setCustomLanguage(lan)
        } else {
            Bundle.recoveryToSystem()
        }
        
        Router.rootWindow = window
        //APNS
        PPNotificationCenter.shared.registerNotice()
        
        //disable dark mode
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        //third part void network speed
        ThirdPartTool.setup()
        
        //for test
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

    //MARK:- APNS
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

