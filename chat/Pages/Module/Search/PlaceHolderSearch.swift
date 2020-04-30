//
//  PlaceHolderSearch.swift
//  chat
//
//  Created by Grand on 2020/3/13.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation

class PlaceHolderSearch: UIView {
    @IBOutlet weak var tipL: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tipL?.text = "Search".localized()
    }
    
}
