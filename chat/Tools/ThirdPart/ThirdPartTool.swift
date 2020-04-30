//
//  ThirdPartTool.swift
//  chat
//
//  Created by Grand on 2020/3/24.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

class ThirdPartTool: NSObject {
    
    static func setup() {
        _setupBugly()
        _setUpUmeng()
    }
    
    fileprivate static func _setupBugly() {
        try? Bugly.start(withAppId: Config.Bugly_APP_ID)
    }
    
    fileprivate static func _setUpUmeng() {
        let appkey = Config.UM_AppKey
        try? UMVisual.setVisualEnabled(true)
        try? UMConfigure.initWithAppkey(appkey, channel: "")
    }
}
