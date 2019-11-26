







import Foundation
import web3swift

enum SignError: Error {
    case unknow
}

@objc public
class CPSignWraper: NSObject {
    
    @objc public
    static func signForRecovery(hash: Data, privateKey: Data) -> Data? {
        let result =
        SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        return result.serializedSignature
    }
    
    @objc public
    static func recoverPublicKey(hash: Data, signature: Data) -> Data? {
        return SECP256K1.recoverPublicKey(hash: hash, signature: signature)
    }
    
    @objc public
    static func OrignSignForRecovery(hash: Data, privateKey: Data) -> Data? {
        let result =
            SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)
        return result.serializedSignature
    }
    
}
