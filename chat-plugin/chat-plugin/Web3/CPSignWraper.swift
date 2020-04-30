//
//  CPSignWraper.swift
//  chat-plugin
//
//  Created by Grand on 2019/10/17.
//  Copyright © 2019 netcloth. All rights reserved.
//

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
    
    //MARK:- v1.1.3
    ///获取一个非压缩的 公钥
    @objc public
    static func recoverUnzipPublicKey(hash: Data, signature_64: Data, judgePubkey_unzip: Data ) -> Data? {
        assert(signature_64.count == 64, "must be 64")
        var recoverySign: Data
        for index in  [27,28,29,30] {
            recoverySign = signature_64
            recoverySign.append(UInt8(index))
            
            if let recoveryPubkey =  SECP256K1.recoverPublicKey(hash: hash, signature: recoverySign) {
                if recoveryPubkey == judgePubkey_unzip {
                    return recoveryPubkey
                }
            }
        }
        return nil
    }
    
}
