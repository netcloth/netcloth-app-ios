//
//  TCSendResultVC.swift
//  chat
//
//  Created by Grand on 2020/4/29.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class TCSendResultVC: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bubbleView?.confirmObserver.sendResultBack?()
    }
}
