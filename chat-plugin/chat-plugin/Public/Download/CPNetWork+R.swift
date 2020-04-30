//
//  NetWork+R.swift
//  chat
//
//  Created by Grand on 2019/8/13.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation

@objc public
class CPNetURL : NSObject {
    
    /// chat to server address
    @objc public static var EnterPointApi: String?
    
    @objc public static var UploadImage: String {
        get {
            return  (EnterPointApi ?? "") + "/v1/image"
        }
    }
    
    @objc public static var RequestImage: String {
        get {
            return (EnterPointApi ?? "") + "/v1/image/{hash}"
        }
    }
    
    @objc public static var getGroupInfo: String {
        get {
            return (EnterPointApi ?? "") + "/v1/group/{pub_key}"
        }
    }
    
    @objc public static var getRecommendationGroup: String {
        get {
            return (EnterPointApi ?? "") + "/v1/group/recommendation"
        }
    }
    
    @objc public static var getAssistantList: String {
        get {
            return (EnterPointApi ?? "") + "/v1/service/customer"
        }
    }
    
    //MARK:- v1.1.7
    @objc public static var setMute: String {
        get {
            return (EnterPointApi ?? "") + "/v1/user/mute"
        }
    }
    @objc public static var setMuteList: String {
        get {
            return (EnterPointApi ?? "") + "/v1/user/mutes"
        }
    }
    
    @objc public static var setBlack: String {
        get {
            return (EnterPointApi ?? "") + "/v1/user/blacklist"
        }
    }
    @objc public static var setBlackList: String {
        get {
            return (EnterPointApi ?? "") + "/v1/user/blacklists"
        }
    }
    
    /// Recall
    @objc public static var getQuryRecallMsgs: String {
        get {
            return (EnterPointApi ?? "") + "/v1/recallmsg/info"
        }
    }
}
