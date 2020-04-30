//
//  ProtocolAlertView.swift
//  chat
//
//  Created by Grand on 2020/4/16.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class ProtocolAlertView: AlertView, NCAlertInterface {
    
    @IBOutlet weak var msgTV: LoginAlertTextView?
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}
