//
//  TokenTradeHistoryVC.swift
//  chat
//
//  Created by Grand on 2020/4/30.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class TokenTradeHistoryVC: BaseViewController {
    
    public var queryNode: CPTradeRsp?
    
    @IBOutlet weak var hubImg: UIImageView?
    @IBOutlet weak var stateL: UILabel?
    @IBOutlet weak var blockNum: UILabel?
    
    @IBOutlet weak var typeL: UILabel?
    @IBOutlet weak var timeL: UILabel?
    
    @IBOutlet weak var totalL: UILabel?
    @IBOutlet weak var feeL: UILabel?
    @IBOutlet weak var toAddrL: UILabel?
    @IBOutlet weak var fromAddrL: UILabel?
    
    @IBOutlet weak var remarkL: UILabel? //备注
    @IBOutlet weak var txhashL: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fixConfigUI()
        requestData()
        self.reloadUI()
    }
    
    func fixConfigUI() {
        typeL?.textAlignment = .right
        timeL?.textAlignment = .right
        totalL?.textAlignment = .right
        feeL?.textAlignment = .right
        toAddrL?.textAlignment = .right
        fromAddrL?.textAlignment = .right
        
        txhashL?.textAlignment = .right
        remarkL?.textAlignment = .right
    }
    
    
    func requestData() {
        guard
            let node = self.queryNode ,
            node.status.rawValue < TradeRspStatus.fail.rawValue
        else {
            return
        }
        
        guard
            let token = NCUserCenter.shared?.walletDataStore.value.assetTokenOf(chainId: Int(node.chainId), symbol: node.symbol)
        else {
           return
        }
        
        let callback = ResultObserver()
        callback.transferQuryTxHashCallBack = { [weak self] (r, txhash) in
            if r {
                node.status = .success
            } else {
                node.status = .fail
            }
            self?.reloadUI()
        }
        token.queryStatus(txHash: node.txhash, callback: callback)
    }
    
    //MARK:- Reload UI
    func reloadUI() {
        guard let node = self.queryNode else {
            return
        }
        
        if node.status == .success {
            hubImg?.image = UIImage(named: "history_ipal_success")
            stateL?.text = "history_Success".localized()
            blockNum?.isHidden = true
        } else if  node.status == .fail {
            hubImg?.image = UIImage(named: "ipal_request_result_fail")
            stateL?.text = "history_Fail".localized()
            blockNum?.isHidden = true
        } else {
            hubImg?.image = UIImage(named: "transfer_send_result")
            stateL?.text = "Confirming".localized()
            blockNum?.isHidden = false
        }
        
        typeL?.text = "trand_Send".localized()
        timeL?.text = NSDate(timeIntervalSince1970: node.createTime).string(withFormat: "yyyy-MM-dd HH:mm:ss")
        
        ///
        var decimal = 12
        var symbol = "NCH"
        if let token = NCUserCenter.shared?.walletDataStore.value.assetTokenOf(chainId: Int(node.chainId), symbol: node.symbol) {
            decimal = token.decimals
            symbol = token.symbol
        }
        totalL?.text = node.amount.toDecimalBalance(bydecimals: decimal)
        
        feeL?.text = node.txfee + symbol
        
        toAddrL?.text = node.toAddr
        fromAddrL?.text = node.fromAddr
        
        ///
        
        
        
        txhashL?.text = node.txhash
        
        if node.memo.isEmpty {
            remarkL?.text = "None".localized()
        }
        else {
            remarkL?.text = node.memo
        }
    }
    
    @IBAction func onTapCopyTxHash() {
        UIPasteboard.general.string = txhashL?.text
        Toast.show(msg: "Copy Success".localized())
    }
    
    @IBAction func toQueryInBrowser() {
        let str = "https://explorer.netcloth.org/transactions/" + getTxHash()
        if let url = URL(string: str) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func getTxHash() -> String {
        return (queryNode?.txhash ?? "")
    }
}
