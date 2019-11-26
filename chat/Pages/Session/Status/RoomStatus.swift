







import Foundation
import AudioToolbox

class RoomStatus {
    
    static var inChatRoom: Bool? = false
    static var appInBackground: Bool = false
    

    static var sessionId: Int?
    static var toPublicKey: String?
    static var remark: String?
}

class MessageAudioManager {
    
    static func playMessageComing(msg:CPMessage? = nil) {
        if RoomStatus.appInBackground {

        } else {
            if RoomStatus.inChatRoom == true {
                shake()
            } else {
                shake()
                smsInAudio()
            }
        }
    }
    

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


