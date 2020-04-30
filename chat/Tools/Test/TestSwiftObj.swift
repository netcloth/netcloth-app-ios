//
//  TestSwiftObj.swift
//  chat
//
//  Created by Grand on 2019/11/15.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import SBJson5

class TestSwiftObj: NSObject {
    
    static func testPubkey() {
        let pubkey = "04652ab1baf227b596eed8523578b25bc22e6ff13ac597dc5d1f28ac9804c4aa6cc7f38b292d3d155638a2c426ed737b86e11f6428b8fec1451c017ba0fd7c9676"
        let compressed = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: pubkey)
        
        if let c = compressed {
            let unc = OC_Chat_Plugin_Bridge.unCompressedHexStrPubkey(ofCompressHexPubkey:c)
            print("decode " + (unc ?? "error"))
        }
    }
    static func pushMsg() {
        PPNotificationCenter.shared.sendALocalNotifyMsg(msg: "ssss")
    }
    
    static func testTransfer() {
        
        let wallet = NCHWallet()
        let token = NCHToken(wallet: wallet, token: [String:Any]())
        token.testSend()

        
        var jsonStr =
        """
        {
            \"account_number\": "\(0)",
            "chain_id": "nch-chain",
            "fee": {
                "amount": [{
                    "amount": "200000000",
                    "denom": "pnch"
                }],
                "gas": "200000"
            },
            "memo": "",
            "msgs": [{
                "type": "nch/MsgSend",
                "value": {
                    "amount": [{
                        "amount": "1",
                        "denom": "pnch"
                    }],
                    "from_address": "nch12dmr99v3eh39f97jnh5ga32ny2ddzznppumf2h",
                    "to_address": "nch12vgxe8qgdnuqlvnvyskua2rssxpqg4yyldrqep"
                }
            }],
            "sequence": "1"
        }
"""
        
        let jD = jsonStr.data(using: String.Encoding.utf8)
        let jsonDic = try? JSONSerialization.jsonObject(with: jD!, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let writer:SBJson5Writer? = SBJson5Writer.writer(withMaxDepth: 20, humanReadable: false, sortKeys: true) as! SBJson5Writer
        
        let jsonData = writer?.data(with: jsonDic)
        
        let datastr = jsonData?.toHexString()
        print(datastr)
        
        let contentHash = jsonData?.sha256()
        
        let prikey = "50aa0816d2f43512564ec41120c91d17224f0d6df9aa1e45d0eeeca97adab213"
        let pkData = NSData(hexString: prikey) as! Data
        
        let sign =
            OC_Chat_Plugin_Bridge.signedContentHash(contentHash, ofUserPrivateKey: pkData)
        
        let signStr = sign?.cpToHexString()
        print(signStr)
        
        let pubkey = "02BBDC958286248620929E2A4A9C84FE0384F502BFBC1A5738F77CE0319A1344D0"
        let pubkey_data = NSData(hexString: pubkey)
        let base64_pub_str = pubkey_data?.base64EncodedString()
        print(base64_pub_str)
        
        let base64_sign = sign?.base64EncodedString()
        print(base64_sign)
    }
    
}
