







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
