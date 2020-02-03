  
  
  
  
  
  
  

import Foundation
import AVFoundation
import Dispatch
import Photos

public protocol Access {
    static func canOpenCamera( autoAccess:Bool?, result: ((_ can:Bool)->Void)?)
}

open class Authorize : Access {
    
    static public func canOpenCamera( autoAccess:Bool?, result: ((_ can:Bool)->Void)?) {
        canOpenMedia(media: .video, autoAccess: autoAccess, result: result)
    }
    
    static public func canOpenPhotoAlbum( autoAccess:Bool?, result: ((_ can:Bool)->Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if let r = result {
                r(true)
            }
        case .notDetermined:
            if let a = autoAccess, a == true {
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        if let r = result {
                            r(status == .authorized)
                        }
                    }
                }
            }
        case .denied,
             .restricted:
            if let r = result {
                r(false)
            }
            
        default:
            print("get auth photo lib")
        }
    }
    
    static public func canOpenMedia(media: AVMediaType, autoAccess:Bool? = true, result: ((_ can:Bool)->Void)? = nil) {
        let status =  AVCaptureDevice.authorizationStatus(for: media)
        switch status {
        case .authorized:
            if let r = result {
                r(true)
            }
        case .notDetermined:
            if let a = autoAccess, a == true {
                AVCaptureDevice.requestAccess(for: media) { (granted) in
                    DispatchQueue.main.async {
                        if let r = result {
                            r(granted)
                        }
                    }
                }
            }
        case .denied,
             .restricted:
            if let r = result {
                r(false)
            }
        default:
            print("get auth")
        }
    }
}


open class Device {
    static public func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
