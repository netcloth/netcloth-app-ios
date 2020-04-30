//
//  TokenTradeListVC.swift
//  chat
//
//  Created by Grand on 2020/4/22.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class TokenTradeListVC: BaseViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum PageTag: String {
        case tradeAll
        case tradeOut
        case tradeIn
        case tradeFail
    }
    var pageTag: PageTag = .tradeAll
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchData()
    }
    
    func configUI() {
        self.tableView.adjustHeader()
        self.tableView.adjustFooter()
        self.tableView.adjustOffset()
    }
    
    func fetchData() {
        self.dataModel?.fetchData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let model = self.dataModel?.source[safe: indexPath.row] as? CPTradeRsp {
            if let vc = R.loadSB(name: "TokenTradeHistoryVC", iden: "TokenTradeHistoryVC") as? TokenTradeHistoryVC {
                vc.queryNode = model
                Router.pushViewController(vc: vc)
            }
        }
        
    }
    
    //MARK:- Helper
    var dataModel: GTableDataModel? {
        
        switch self.pageTag {
        case .tradeAll:
            return model_all
        case .tradeOut:
            return model_out
        case .tradeIn:
            return model_in
        case .tradeFail:
            return model_fail
        default:
            return nil
        }
    }
    
    //MARK:- all
    lazy var model_all: GTableDataModel = {
        let all = GTableDataModel(table: self.tableView, originDelegate: self)
        let chainId = self.token?.wallet.chainID ?? 0
        let symbol = self.token?.symbol ?? "NCH"
        
        all.config.onFetchDataTrigger = { [weak self] (callback) in
            CPAssetTokenHelper.getAllTradeRecordWhere(chainId, symbol: symbol, tid: -1, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        
        all.config.onLoadMoreTrigger =  { [weak self] (last , callback) in
            
            guard let record = last as? CPTradeRsp else {
                return
            }
            CPAssetTokenHelper.getAllTradeRecordWhere(chainId, symbol: symbol, tid: record.tid, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        return all
    }()
    
    //MARK:- out
    lazy var model_out: GTableDataModel = {
        let all = GTableDataModel(table: self.tableView, originDelegate: self)
        let chainId = self.token?.wallet.chainID ?? 0
        let symbol = self.token?.symbol ?? "NCH"
        
        all.config.onFetchDataTrigger = { [weak self] (callback) in
            CPAssetTokenHelper.getTradeOutRecordWhere(chainId, symbol: symbol, tid: -1, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        
        all.config.onLoadMoreTrigger =  { [weak self] (last , callback) in
            
            guard let record = last as? CPTradeRsp else {
                return
            }
            CPAssetTokenHelper.getTradeOutRecordWhere(chainId, symbol: symbol, tid: record.tid, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        return all
    }()
    
    //MARK:- in
    lazy var model_in: GTableDataModel = {
        let all = GTableDataModel(table: self.tableView, originDelegate: self)
        let chainId = self.token?.wallet.chainID ?? 0
        let symbol = self.token?.symbol ?? "NCH"
        
        all.config.onFetchDataTrigger = { [weak self] (callback) in
            CPAssetTokenHelper.getTradeInRecordWhere(chainId, symbol: symbol, tid: -1, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        
        all.config.onLoadMoreTrigger =  { [weak self] (last , callback) in
            
            guard let record = last as? CPTradeRsp else {
                return
            }
            CPAssetTokenHelper.getTradeInRecordWhere(chainId, symbol: symbol, tid: record.tid, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        return all
    }()
    
    //MARK:- fail
    lazy var model_fail: GTableDataModel = {
        let all = GTableDataModel(table: self.tableView, originDelegate: self)
        let chainId = self.token?.wallet.chainID ?? 0
        let symbol = self.token?.symbol ?? "NCH"
        
        all.config.onFetchDataTrigger = { [weak self] (callback) in
            CPAssetTokenHelper.getTradeFailRecordWhere(chainId, symbol: symbol, tid: -1, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        
        all.config.onLoadMoreTrigger =  { [weak self] (last , callback) in
            
            guard let record = last as? CPTradeRsp else {
                return
            }
            CPAssetTokenHelper.getTradeFailRecordWhere(chainId, symbol: symbol, tid: record.tid, size: 20) { (r, msg, arrays) in
                callback(arrays)
            }
        }
        return all
    }()
    
    //MARK:- helper
    fileprivate var token: TokenInterface? {
        return (self.parent?.parent as? TokenDetailVC)?.token
    }
}
