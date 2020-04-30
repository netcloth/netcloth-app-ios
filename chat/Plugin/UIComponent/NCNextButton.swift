//
//  NCNextButton.swift
//  chat
//
//  Created by Grand on 2020/4/23.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class NCNextButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setShadow(color: self.backgroundColor ?? UIColor(hexString: Color.shadow_Layer)!,
                       offset: CGSize(width: 0,height: 10),
                       radius: 20,
                       opacity: 0.2)
    }
}
