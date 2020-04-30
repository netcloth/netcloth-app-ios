//
//  IPALDetailVC.swift
//  chat
//
//  Created by Grand on 2019/11/13.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class IPALDetailVC: BaseViewController {
    
    @IBOutlet weak var line1 : UILabel?
    @IBOutlet weak var line2 : UILabel?
    @IBOutlet weak var line3 : UILabel?

    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            // Fallback on earlier versions
        }
        
        super.viewDidLoad()
        self.configUI()
    }
    
    func configUI() {
        self.line1?.preferredMaxLayoutWidth = YYScreenSize().width - 30
        self.line2?.preferredMaxLayoutWidth = YYScreenSize().width - 30
        self.line3?.preferredMaxLayoutWidth = YYScreenSize().width - 30
    }
}
