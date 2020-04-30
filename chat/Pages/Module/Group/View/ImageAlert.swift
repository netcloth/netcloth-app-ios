//
//  ImageAlert.swift
//  chat
//
//  Created by Grand on 2020/3/24.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

class ImageAlert: AlertView , NCAlertInterface {
    
    @IBOutlet weak var imageV: UIImageView?
    @IBOutlet weak var bottomL: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bottomL?.textColor = UIColor(hexString: Color.black)
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
    
    func ncAutoDismiss() -> Bool {
        return true
    }
}

