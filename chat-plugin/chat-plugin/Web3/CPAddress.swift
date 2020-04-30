//
//  CPAddress.swift
//  chat-plugin
//
//  Created by Grand on 2019/11/7.
//  Copyright © 2019 netcloth. All rights reserved.
//

import Foundation
import web3swift

enum AddressError: Error {
    case unknow
}

@objc public
class CPAddressWraper: NSObject {
    
    @objc public
    static func addressForPrivateKey(_ privateKey: Data) throws -> String  {
        
        //compressed pubkey
        guard let compressedPubkey = Web3.Utils.privateToPublic(privateKey, compressed: true) else {
            throw AbstractKeystoreError.keyDerivationError
        }
        let sha = compressedPubkey.sha256()
        
        let bytes20 = try RIPEMD160.hash(message: sha)
        
        if let r = Bech32.parseFallbackAddress(data: bytes20) {
            return r;
        }
        throw AddressError.unknow
        //this is eth address
//        guard let addr = Web3.Utils.publicToAddress(pubKey) else {throw AbstractKeystoreError.keyDerivationError}
//        self.address = addr
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
