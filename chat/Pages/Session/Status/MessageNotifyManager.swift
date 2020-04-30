//
//  File.swift
//  chat
//
//  Created by Grand on 2019/12/4.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

class MessageNotifyManager {
    
    static func playMessageComing(msg:CPMessage? = nil) {
        
        if RoomStatus.appInBackground {
        }
        else {
            if RoomStatus.inChatRoom == true {
                shake()
            } else {
                shake()
                smsInAudio()
            }
        }
    }
    
    //MARK:- private
    static private func shake() {
        if Config.Settings.shakeble == false {
            return
        }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    static var sound:SystemSoundID = 0
    private static func smsInAudio() {
        if Config.Settings.bellable == false {
            return
        }
        //http://iphonedevwiki.net/index.php/AudioServices
        if sound == 0 {
            let path = "/System/Library/Audio/UISounds/sms-received1.caf"
            if let url = (NSURL.fileURL(withPath: path) as? CFURL) {
                let error = AudioServicesCreateSystemSoundID(url , &sound)
                if(error != kAudioServicesNoError) {
                    sound = 0;
                }
            }
        }
        if sound != 0 {
            AudioServicesPlaySystemSound(sound);
        }
    }
    
    private static func sendLocalNotice(msg:CPMessage? = nil) {
        PPNotificationCenter.shared.sendALocalNotice(msg: msg)
    }
}
