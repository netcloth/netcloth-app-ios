
//
//  IPALHistoryDetailVC.swift
//  chat
//
//  Created by Grand on 2019/11/10.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class IPALHistoryDetailVC: BaseViewController {

    public var queryHistoryNode: CPChainClaim?
    public var queryHistoryTxHash: String?
    
    
    @IBOutlet weak var hubImg: UIImageView?
    @IBOutlet weak var stateL: UILabel?
    @IBOutlet weak var blockNum: UILabel?
    
    @IBOutlet weak var typeL: UILabel?
    @IBOutlet weak var timeL: UILabel?
    @IBOutlet weak var nodeNameL: UILabel?
    @IBOutlet weak var txhashL: UILabel?
    @IBOutlet weak var remarkL: UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fixConfigUI()
        dispatchRequest()
    }
    
    func fixConfigUI() {
        typeL?.textAlignment = .right
        timeL?.textAlignment = .right
        nodeNameL?.textAlignment = .right
        txhashL?.textAlignment = .right
        remarkL?.textAlignment = .right
    }
    
    
    func dispatchRequest() {
        
        if queryHistoryTxHash != nil  ||  queryHistoryNode?.chain_status == 0 {
            let hash =  getTxHash()
            if queryHistoryTxHash != nil {
                CPAssetHelper.getObjectWhereTxHash(hash) { (r, obj) in
                    if obj != nil {
                        self.queryHistoryNode = obj
                        self.requestData(hash: hash)
                        self.reloadUI()
                    } else {
                        self.reloadUI()
                    }
                }
            } else {
                self.requestData(hash: hash)
                self.reloadUI()
            }
        } else {
            self.reloadUI()
        }
    }
    
    func requestData(hash: String) {
        IPALManager.shared.onQueryBlockStatusInfo(txHash: hash, requestCount: 0, complete: { r in
            if r {
                self.queryHistoryNode?.chain_status = 1
            } else {
                self.queryHistoryNode?.chain_status = 2
            }
            self.reloadUI()
        })
    }
    
    //MARK:- Reload UI

    func reloadUI() {
        if let n = self.queryHistoryNode {
            typeL?.text = "Communication Server Claim".localized()
            timeL?.text = NSDate(timeIntervalSince1970: n.createTime).string(withFormat: "yyyy-MM-dd HH:mm:ss")
            nodeNameL?.text = n.moniker
            txhashL?.text = n.txhash
            remarkL?.text =  "None".localized()
            
            if n.chain_status == 0 {
                hubImg?.image = UIImage(named: "ipal_request_result_ing")
                stateL?.text = "history_Pending".localized()
                blockNum?.isHidden = false
            } else if n.chain_status == 1 {
                hubImg?.image = UIImage(named: "history_ipal_success")
                stateL?.text = "history_Success".localized()
                blockNum?.isHidden = true
            } else if  n.chain_status == 2 {
                hubImg?.image = UIImage(named: "ipal_request_result_fail")
                stateL?.text = "history_Fail".localized()
                blockNum?.isHidden = true
            }
        }
    }
    
    @IBAction func onTapCopyTxHash() {
        UIPasteboard.general.string = txhashL?.text
        Toast.show(msg: "Copy Success".localized())
    }
    
    @IBAction func toQueryInBrowser() {
        let str = "https://explorer.netcloth.org/transactions/" + (queryHistoryTxHash ?? queryHistoryNode?.txhash ?? "")
        if let url = URL(string: str) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func getTxHash() -> String {
         return (queryHistoryTxHash ?? queryHistoryNode?.txhash ?? "")
    }
    
}
