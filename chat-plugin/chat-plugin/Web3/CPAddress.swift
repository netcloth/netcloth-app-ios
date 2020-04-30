







import Foundation
import web3swift

enum AddressError: Error {
    case unknow
}

@objc public
class CPAddressWraper: NSObject {
    
    @objc public
    static func addressForPrivateKey(_ privateKey: Data) throws -> String  {
        
        
        guard let compressedPubkey = Web3.Utils.privateToPublic(privateKey, compressed: true) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        let sha = compressedPubkey.sha256()
        
        let bytes20 = try RIPEMD160.hash(message: sha)
        
        if let r = Bech32.parseFallbackAddress(data: bytes20) {
            return r;
        }
        throw AddressError.unknow
        


    }
    
    
    @objc public
    static func compressedHexPubkey(_ originPubkey: Data) throws -> String  {
        if let compressedData = SECP256K1.combineSerializedPublicKeys(keys: [originPubkey], outputCompressed: true) {
            return compressedData.toHexString()
        }
        throw AddressError.unknow
    }
    
    @objc public
    static func unCompressedHexPubkey(_ originPubkey: Data) throws -> String  {
        if let compressedData = SECP256K1.combineSerializedPublicKeys(keys: [originPubkey], outputCompressed: false) {
            return compressedData.toHexString()
        }
        throw AddressError.unknow
    }
    
}
