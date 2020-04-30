//
//  GTableDataModel.swift
//  chat
//
//  Created by Grand on 2020/4/22.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class GTableDataModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate var list: [Any] = []
    
    var source: [Any] {
        return list
    }
    
    fileprivate var delegateContainer: GTableDelegateContainer?
    
    weak var tableView: UITableView?
    //MARK:-  Lifecycle
    required init(table: UITableView,originDelegate: AnyObject? = nil) {
        tableView = table
        super.init()
        
        let dc = GTableDelegateContainer()
        delegateContainer = dc
        if let o = originDelegate {
            dc.addDelegate(o)
        }
        dc.addDelegate(self)
        
        table.delegate = dc as! UITableViewDelegate
        table.dataSource = dc as! UITableViewDataSource
        
        /// config default cell
        self.config.onCellForRowAt = { [weak self] (indexPath) -> UITableViewCell in
            let model = self?.list[indexPath.row]
            let cell = self?.tableView?.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell?.reloadData(data: model)
            return cell ?? UITableViewCell()
        }
    }
        
    class SourceConfig {
        //MARK:-  Config
        var onFetchDataTrigger: ( (_ callback: @escaping ([Any]?) -> Void) -> Void)?
        var onCellForRowAt: ((_ indexPath:IndexPath) -> UITableViewCell)?
        
        /// load more
        var onLoadMoreTrigger: ( ( _ lastModel: Any , _ callback: @escaping ([Any]?) -> Void) -> Void)?
    }
    
    lazy var config = SourceConfig()
    fileprivate var inLoadIngMore: Bool = false
    fileprivate var hasMoreData: Bool = true

    
    //MARK:-  Public
    func fetchData() {
        
        let callback = { (r: [Any]?) in
            let result = r ?? []
            self.list = result
            self.hasMoreData = true
            self.tableView?.reloadData()
        }
        self.config.onFetchDataTrigger?(callback)
    }
    
    //MARK:-  TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.config.onCellForRowAt?(indexPath) {
            
            
            guard indexPath.row >= self.list.count - 3,
                let last = self.list.last,
                inLoadIngMore == false,
                hasMoreData == true else {
                    return cell
            }
            
            inLoadIngMore = true
            
            let callback = { (r: [Any]?) in
                let result = r ?? []
                self.list.append(contentsOf: result)
                self.inLoadIngMore = false
                if result.isEmpty {
                    self.hasMoreData = false
                }
                self.tableView?.reloadData()
            }
            self.config.onLoadMoreTrigger?(last, callback)
            return cell
        }
        return UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
    }
}
