//
//  NCCommonUseTableVC.swift
//  chat
//
//  Created by Grand on 2019/11/19.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class NCCommonUseTableVC: BaseTableViewController {
    
    @IBOutlet weak var recordL: UILabel?

    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            // Fallback on earlier versions
        }
        super.viewDidLoad()
        self.tableView.adjustFooter()
    }
}
