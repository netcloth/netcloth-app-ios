







import UIKit
import CoreLocation
import AVFoundation

class KeepAlive: NSObject {
    static var locationManger: CLLocationManager?
    static var player: AVAudioPlayer?
    
    static var bgTaskID: UIBackgroundTaskIdentifier?
    static var timer: Timer?
    
    private static let delegate:Delegate = Delegate()
    
    private class Delegate: NSObject, CLLocationManagerDelegate,AVAudioPlayerDelegate {
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedAlways  || status == .authorizedWhenInUse {
                KeepAlive.openLocation()
            }
        }
        

        func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
            if player.isPlaying == false {
                try? AVAudioSession.sharedInstance().setActive(true)
                player.prepareToPlay()
                player.play()
            }
        }
        
        @objc func audioSessionInterruption(notification: NSNotification) {
            guard (player != nil) else {return}
            guard let userinfo = notification.userInfo else {return}
            guard let interruptionType: UInt = userinfo[AVAudioSessionInterruptionTypeKey] as! UInt?  else {return}
            if interruptionType == AVAudioSession.InterruptionType.began.rawValue {

                debugPrint("\(type(of:self)): 中断开始 userinfo:\(userinfo)")
            } else if interruptionType == AVAudioSession.InterruptionType.ended.rawValue {

                debugPrint("\(type(of:self)): 中断结束 userinfo:\(userinfo)")
                if player?.isPlaying == false {
                    try? AVAudioSession.sharedInstance().setActive(true)
                    player?.prepareToPlay()
                    player?.play()
                }
            }
        }
        
    }
    



    class func startLocation(){
        startTimer()
        setUpLocation()
    }
    

    class func startSilenceAudio() {
        startTimer()
        setupPlayer()
    }
    
    class func stop() {
        stopTimer()
        locationManger?.stopUpdatingLocation()
        locationManger = nil
        NotificationCenter.default.removeObserver(delegate)
        player?.stop()
        player = nil
    }
    
    

    private static func setupPlayer () {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error {
            debugPrint("\(type(of:self)):\(error)")
        }
        
        do {
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "WhatYouWant", ofType: "mp3")!))
        } catch let error {
            debugPrint("\(type(of:self)):\(error)")
        }
        player?.numberOfLoops = -1
        player?.volume = 0
        player?.delegate = delegate
        player?.prepareToPlay()
        player?.play()
        
        NotificationCenter.default.removeObserver(delegate)
        
        NotificationCenter.default.addObserver(delegate, selector: #selector(delegate.audioSessionInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    
    
    private static func openLocation() {
        locationManger?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManger?.allowsBackgroundLocationUpdates = true
        locationManger?.startUpdatingLocation()
    }
    private static func setUpLocation() {
        if CLLocationManager.locationServicesEnabled() == false {
            return
        }
        let status = CLLocationManager.authorizationStatus()
        if locationManger == nil {
            locationManger = CLLocationManager()
        }
        
        switch status {
        case .notDetermined,
             .restricted:
            locationManger?.delegate = delegate
            locationManger?.requestAlwaysAuthorization()
        default:
            openLocation()
        }
    }
    
    
    private static func startTimer () {
        timer?.invalidate()
        timer = nil
        timer = Timer(timeInterval: 15, repeats: true, block: { (time) in
            
            if UIApplication.shared.backgroundTimeRemaining < 20 {
                if let bid = bgTaskID {
                    UIApplication.shared.endBackgroundTask(bid)
                }
                bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                    UIApplication.shared.endBackgroundTask((bgTaskID)!)
                    bgTaskID = UIBackgroundTaskIdentifier.invalid
                })
            }
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        timer?.fire()
    }
    
    private static func stopTimer() {
        if let bid = bgTaskID {
            UIApplication.shared.endBackgroundTask(bid)
        }
        timer?.invalidate()
        timer = nil
    }
}


