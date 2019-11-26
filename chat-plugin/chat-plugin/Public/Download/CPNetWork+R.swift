







import Foundation

@objc public
class CPNetURL : NSObject {
    
    @objc public
    static var EnterPointApi: String?
    
    @objc public
    static var UploadImage: String {
        get {
            return  (EnterPointApi ?? "") + "/v1/image"
        }
    }
    
    @objc public
    static var RequestImage: String {
        get {
            return (EnterPointApi ?? "") + "/v1/image/{hash}"
        }
    }
}
