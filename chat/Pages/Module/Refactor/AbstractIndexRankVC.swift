//
//  IndexRankVC.swift
//  chat
//
//  Created by Grand on 2019/12/5.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class AbstractIndexRankVC: BaseViewController,
UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    let disbag = DisposeBag()
    
    var indexArray: [String] = []
    var models: [String: [CPContact]] = [:]
    
    
    //MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.requestData()
    }
    
    //MARK:- Overwrite
    func requestData() {
        fatalError("must overwrite")
    }
    
    func onTap(row: IndexPath, model: CPContact?) {
        fatalError("must overwrite")
    }
    
    func cellFor(row: IndexPath) -> UITableViewCell {
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "cell", for: row) as! ContactCell
        return cell
    }
    
    //MARK:- UI
    func fillData(_ contacts: [CPContact]?) {
        
        let contacts: [CPContact]? = contacts
        
        //group
        self.models.removeAll()
        if let array = contacts {
            for contact in array {
                
                let title = contact.remark as NSString
                let letters = PinyinHelper.toHanyuPinyinStringArray(withChar: title.character(at: 0)) as? [String]
                let firstCharacter = String(letters?.first?.prefix(1) ?? (title as String).prefix(1))
                
                let index = firstCharacter.isEnglish() ? firstCharacter.uppercased() : "#"
                
                var indexArr = self.models[index]
                
                if indexArr == nil {
                    indexArr = [CPContact]()
                    indexArr?.append(contact)
                    self.models[index] = indexArr
                } else {
                    indexArr?.append(contact)
                    self.models[index] = indexArr
                }
            }
        }
        
        //sort index
        let titles = self.models.keys.sorted(by: { l, r in
            let lIsEn = l.isEnglish()
            let rIsEn = r.isEnglish()
            if lIsEn, rIsEn {
                return l < r
            }
            return lIsEn
        })
        self.indexArray = titles ?? []
        
        self.tableView?.reloadData()
    }
    
    func configUI() {
        
        self.tableView?.adjustHeader()
        self.tableView?.adjustFooter()
        
        self.tableView?.adjustOffset()
        self.tableView?.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        
        self.tableView?.sectionIndexColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
        self.tableView?.sectionIndexTrackingBackgroundColor = UIColor.clear
        self.tableView?.sectionIndexBackgroundColor = UIColor.clear
        
        self.tableView?.register(ContactSectionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }
    
    func configEvent() {
        
    }
}

extension AbstractIndexRankVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models[indexArray[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cellFor(row: indexPath)
        
        let key = indexArray[indexPath.section]
        let model = self.models[key]?[indexPath.row]
        
        cell.reloadData(data: model as Any)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = indexArray[indexPath.section]
        let model = self.models[key]?[indexPath.row]
        self.onTap(row: indexPath, model: model)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let title = indexArray[safe: section]
        
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let _ = header as? ContactSectionHeader {
        } else {
            header = ContactSectionHeader(reuseIdentifier: "header")
        }
        
        (header as? ContactSectionHeader)?.leftText?.text = title
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

//MARK:- Index
extension AbstractIndexRankVC {
    
    //numbers
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexArray
    }
    
    //selection
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
}


