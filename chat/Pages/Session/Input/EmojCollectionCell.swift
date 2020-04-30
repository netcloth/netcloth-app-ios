//
//  EmojCollectionCell.swift
//  chat
//
//  Created by Grand on 2019/8/30.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class EmojCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func reloadData(data: Any) {
        guard let ts = data as? String else { return }
        self.textLabel.text = ts
    }
}
