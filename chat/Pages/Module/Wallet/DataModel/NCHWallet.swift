//
//  NCHWallet.swift
//  chat
//
//  Created by Grand on 2020/4/13.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation
import SBJson5
import Alamofire

class NCHWallet: WalletInterface  {
    
    var chainID: Int32 = 0
    var identify: Wallet = .NCH
    
    var name: String {
        if Bundle.is_zh_Hans() {
            return self.identify.rawValue + "Wallet".localized()
        }
        else {
            return self.identify.rawValue + " " + "Wallet".localized()
        }
    }
    
    var logo: UIImage {
        return UIImage(named: identify.rawValue)!
    }
    
    var address: String = OC_Chat_Plugin_Bridge.addressOfLoginUser() ?? ""
    
    
    fileprivate lazy var _tokens: [TokenInterface] = {
        let jsonfilepath = Bundle.main.path(forResource: "chain", ofType: "json") ?? ""
        
        guard let stream = NSData(contentsOfFile: jsonfilepath) as? Data,
            let array = (try? JSONSerialization.jsonObject(with: stream, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSArray,
            let nchDic = array[0] as? NSDictionary,
            let tokenDic = nchDic["token"] as? [String : Any] else {
                return []
        }
        let token = NCHToken(wallet: self, token: tokenDic)
        return [token]
    }()
    var assetTokens: [TokenInterface] {
        return _tokens
    }
}

//MARK:- Token
class NCHToken: AbstractToken {
    
    override var logo: UIImage? {
        return UIImage(named: "NCH_Token")
    }
    
    func testSend() {
        return
        let account_number = "0"
        
        let fromaddress = "nch12dmr99v3eh39f97jnh5ga32ny2ddzznppumf2h"
        let privateKeyData = NSData(hexString: "50aa0816d2f43512564ec41120c91d17224f0d6df9aa1e45d0eeeca97adab213")
        var mePubkey = "02BBDC958286248620929E2A4A9C84FE0384F502BFBC1A5738F77CE0319A1344D0"
        
//        let testMePubkey = OC_Chat_Plugin_Bridge.hexPublicKey(fromPrivatekey: privateKeyData! as Data)
//        let tmpbukey = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: testMePubkey)
        
        let memo = ""
        let toAddress = "nch12vgxe8qgdnuqlvnvyskua2rssxpqg4yyldrqep"
        let amount = "1"
        let sequence = "1"
        
        
        var jsonStr =
        """
        {
        "account_number": "\(account_number)",
        "chain_id": "nch-chain",
        "fee": {
        "amount": [{
        "amount": "200000000",
        "denom": "pnch"
        }],
        "gas": "200000"
        },
        "memo": "\(memo)",
        "msgs": [{
        "type": "nch/MsgSend",
        "value": {
        "amount": [{
        "amount": "\(amount)",
        "denom": "pnch"
        }],
        "from_address": "\(fromaddress)",
        "to_address": "\(toAddress)"
        }
        }],
        "sequence": "\(sequence)"
        }
        """
        
        let jD = jsonStr.data(using: String.Encoding.utf8)
        let jsonDic = try? JSONSerialization.jsonObject(with: jD!, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let writer:SBJson5Writer? = SBJson5Writer.writer(withMaxDepth: 20, humanReadable: false, sortKeys: true) as! SBJson5Writer
        
        let jsonData = writer?.data(with: jsonDic)
        let contentHash = jsonData?.sha256()
        
        let sign = OC_Chat_Plugin_Bridge.signedContentHash(contentHash, ofUserPrivateKey: privateKeyData! as Data)
        
        
        mePubkey = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: mePubkey) ?? ""
        let mePubkey_data =  NSData(hexString: mePubkey)
        
        guard
            let mePubkeyBase64 = mePubkey_data?.base64EncodedString(),
            let signBase64 = sign?.base64EncodedString() else {
                return
        }
        
        var transfer_json =
        """
        {
        "tx": {
        "msg": [{
        "type": "nch/MsgSend",
        "value": {
        "from_address": "\(fromaddress)",
        "to_address": "\(toAddress)",
        "amount": [{
        "denom": "pnch",
        "amount": "\(amount)"
        }]
        }
        }],
        "fee": {
        "amount": [{
        "denom": "pnch",
        "amount": "200000000"
        }],
        "gas": "200000"
        },
        "memo": "\(memo)",
        "signatures": [{
        "pub_key": {
        "type": "tendermint/PubKeySecp256k1",
        "value": "\(mePubkeyBase64)"
        },
        "signature": "\(signBase64)"
        }]
        },
        "mode": "block"
        }
        """
        
        let transferD = transfer_json.data(using: String.Encoding.utf8)
        let transferDic = try? JSONSerialization.jsonObject(with: transferD!, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let transferData = writer?.data(with: transferDic)
        let tttstri = transferData?.cpToHexString()
        print(tttstri!)
        
        guard let uploadData = transferData else {
            return
        }
        
        
        let headers : HTTPHeaders = [HTTPHeader.contentType("application/json"),
                                     HTTPHeader.accept("application/json")]
        
        NW.uploadHttp(body: uploadData,
                      toUrl: "http://192.168.1.107:1317/txs",
                      headers: headers) { [weak self] (r, response) in
                        let json = JSON(response)
                        if r ,
                            let txhash = json["txhash"].string,
                            let code = json["logs"][0]["success"].bool,
                            code == true {
                            
                            /// TODO: add db
                            //暂时成功，去查询
                            print("success \(json.rawString())")
                        }
                        else {
                            ///校验失败
                           print("fail \(json.rawString())")
                        }
        }
    }

    
    override func isValidAddress(addr: String) -> Bool {
        guard addr.hasPrefix("nch"),
            addr.count == 42 else {
                return false
        }
        return true
    }
    
    override func transferTo(address: String,
                             amount: String,
                             memo: String = "",
                             callback: ResultObserver) -> Void {
        
        self.getAccountInfo().subscribe(onNext: { [weak self] (arg0) in
            let (account_number, sequence) = arg0
            self?.step2Transfer(toAddress: address, amount: amount, account_number: account_number, sequence: sequence, memo: memo, callback: callback)
            
        }, onError: { (error) in
            callback.transferCallBack?(false, nil)
        })
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - toAddress: nchXX
    ///   - amount: pnch
    ///   - account_number: <#account_number description#>
    ///   - sequence: <#sequence description#>
    ///   - memo:备注
    fileprivate func step2Transfer(toAddress: String,
                                   amount: String,
                                   account_number: String,
                                   sequence:String,
                                   memo: String = "",
                                   callback: ResultObserver) {
        
        let fromaddress = self.wallet.address
        var jsonStr =
        """
        {
        "account_number": "\(account_number)",
        "chain_id": "nch-testnet",
        "fee": {
        "amount": [{
        "amount": "200000000",
        "denom": "pnch"
        }],
        "gas": "200000"
        },
        "memo": "\(memo)",
        "msgs": [{
        "type": "nch/MsgSend",
        "value": {
        "amount": [{
        "amount": "\(amount)",
        "denom": "pnch"
        }],
        "from_address": "\(fromaddress)",
        "to_address": "\(toAddress)"
        }
        }],
        "sequence": "\(sequence)"
        }
        """
        
        let jD = jsonStr.data(using: String.Encoding.utf8)
        let jsonDic = try? JSONSerialization.jsonObject(with: jD!, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let writer:SBJson5Writer? = SBJson5Writer.writer(withMaxDepth: 20, humanReadable: false, sortKeys: true) as! SBJson5Writer
        
        let jsonData = writer?.data(with: jsonDic)
        let contentHash = jsonData?.sha256()
        
        let sign = OC_Chat_Plugin_Bridge.signedLoginUser(toContentHash: contentHash)
        
        var mePubkey = CPAccountHelper.loginUser()?.publicKey ?? ""
        mePubkey = OC_Chat_Plugin_Bridge.compressedHexStrPubkey(ofHexPubkey: mePubkey) ?? ""
        let mePubkey_data =  NSData(hexString: mePubkey)
        
        guard
            let mePubkeyBase64 = mePubkey_data?.base64EncodedString(),
            let signBase64 = sign?.base64EncodedString() else {
                callback.transferCallBack?(false,nil)
                return
        }
        
        var transfer_json =
        """
        {
        "tx": {
        "msg": [{
        "type": "nch/MsgSend",
        "value": {
        "from_address": "\(fromaddress)",
        "to_address": "\(toAddress)",
        "amount": [{
        "denom": "pnch",
        "amount": "\(amount)"
        }]
        }
        }],
        "fee": {
        "amount": [{
        "denom": "pnch",
        "amount": "200000000"
        }],
        "gas": "200000"
        },
        "memo": "\(memo)",
        "signatures": [{
        "pub_key": {
        "type": "tendermint/PubKeySecp256k1",
        "value": "\(mePubkeyBase64)"
        },
        "signature": "\(signBase64)"
        }]
        },
        "mode": "sync"
        }
        """
        
        let transferD = transfer_json.data(using: String.Encoding.utf8)
        let transferDic = try? JSONSerialization.jsonObject(with: transferD!, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        let transferData = writer?.data(with: transferDic)
        
        let tttstri = transferData?.cpToHexString()
        print(tttstri!)
        
        guard let uploadData = transferData else {
            callback.transferCallBack?(false,nil)
            return
        }
        
        let headers : HTTPHeaders = [HTTPHeader.contentType("application/json"),
                                     HTTPHeader.accept("application/json")]
        
        
        var path = APPURL.Chain.broadcastTransfer
        
        let now = NSDate().timeIntervalSince1970
        NW.uploadHttp(body: uploadData,
                      toUrl: path,
                      headers: headers) { [weak self] (r, response) in
                        
                        let json = JSON(response)
                        /// insert db
                        let chainId = self?.wallet.chainID ?? 12
                        let symbol = self?.symbol ?? "NCH"
                        if let txhash = json["txhash"].string,
                            txhash.isEmpty == false {
                            let trade = CPTradeRsp()
                            trade.txhash = txhash
                            trade.type = .transfer
                            trade.status = .query
                            trade.createTime = now

                            ///eg: pnch
                            trade.amount = amount

                            trade.chainId = chainId
                            trade.symbol = symbol

                            ///eg: nch
                            trade.txfee = "0.0002";

                            trade.fromAddr = fromaddress
                            trade.toAddr = toAddress;

                            /// 备注
                            trade.memo = memo;
                            
                            CPAssetTokenHelper.insert(trade, callback: nil)
                        }
                        
                        
                        if let txhash = json["txhash"].string {
                            let code = json["code"].stringValue
                            if code.count > 0 {
                                CPAssetTokenHelper.updateTrade(.fail, where: chainId,
                                                               symbol: symbol,
                                                               txhash: txhash, callback: nil)
                                callback.transferCallBack?(false,nil)
                            }
                            else {
                                //暂时成功，去查询 txhash
                                callback.transferCallBack?(true, txhash)
                                self?.step3QueryStatus(txHash: txhash, callback: callback)
                            }
                        }
                        else {
                            callback.transferCallBack?(false,nil)
                        }
        }
    }
    
    fileprivate func step3QueryStatus(txHash: String, callback: ResultObserver) {
        
        let path = APPURL.Chain.QueryBlockHashStatus.replacingOccurrences(of: "{tx_hash}", with: txHash)
        
        let chainId = self.wallet.chainID
        let symbol = self.symbol

        
        TaskRun.runTask(task: { (resume) in
            
            NW.getJsonUrl(path: path, method: .get, para: nil) { (r, res) in
                let json = JSON(res)
                if r ,
                    let code = json["logs"][0]["success"].bool,
                    code == true {
                    CPAssetTokenHelper.updateTrade(.success, where: chainId,
                                                   symbol: symbol,
                                                   txhash: txHash, callback: nil)
                    callback.transferQuryTxHashCallBack?(true, txHash)
                    resume(false)
                }
                else {
                    resume(true)
                }
            }
            
        }, overcount: {
            CPAssetTokenHelper.updateTrade(.fail, where: chainId,
                                           symbol: symbol,
                                           txhash: txHash, callback: nil)
            callback.transferQuryTxHashCallBack?(false,txHash)
        })
    }
    
    
    
    
    fileprivate func getAccountInfo() -> Observable<(account_number:String,sequence:String)>{
        return Observable.create { [weak self] (observer) -> Disposable in
            
            let addr = self?.wallet.address ?? ""
            let path = APPURL.Chain.accountsInfo.replacingOccurrences(of: "{addr}", with: addr)
            NW.requestUrl(path: path) { (r, response) in
                if r {
                    let json = JSON(response)
                    if let account_number = json["result"]["value"]["account_number"].string,
                        let sequence = json["result"]["value"]["sequence"].string
                    {
                        let seq_add = sequence //sequence.bui_add(number: 1)
                        observer.onNext((account_number, seq_add))
                    }
                    else {
                        observer.onError(NSError(domain: "transfer", code: 1, userInfo: nil))
                    }
                }
                else {
                    observer.onError(NSError(domain: "transfer", code: 1, userInfo: nil))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    
    
    override func fetchBalanceObserver() ->  Observable<String> {
        return Observable.create { [weak self] (observer) -> Disposable in
            
            let addr = self?.wallet.address ?? ""
            let path = APPURL.Chain.balanceOfAddress.replacingOccurrences(of: "{addr}", with: addr)
            NW.requestUrl(path: path) { (r, response) in
                if r {
                    let json = JSON(response)
                    if var amount = json["result"][0]["amount"].string {
                        if amount.isEmpty {
                            amount = "0"
                        }
                        self?.storeCurrentBalance(balance: amount)
                        
                        observer.onNext(amount)
                    }
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    override func queryStatus(txHash: String, callback: ResultObserver) {
        self.step3QueryStatus(txHash: txHash, callback: callback)
    }
}
