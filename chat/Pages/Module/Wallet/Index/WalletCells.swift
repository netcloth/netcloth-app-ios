//
//  WalletCells.swift
//  chat
//
//  Created by Grand on 2020/4/14.
//  Copyright © 2020 netcloth. All rights reserved.
//

import Foundation


@objc class WalletCategoryCell: UITableViewCell {
    @IBOutlet weak var logo: UIImageView?
    override func reloadData(data: Any) {
        if let wallet = data as? WalletInterface {
            self.logo?.image = wallet.logo
        }
    }
    
    func selectBg() {
        self.contentView.backgroundColor = UIColor(hexString: Color.gray_f4)
    }
    
    func deselectBg() {
        self.contentView.backgroundColor = UIColor.white
    }
}



@objc class WalletListCell: UITableViewCell {
    @IBOutlet weak var nameL : UILabel?
    @IBOutlet weak var idenL : PaddingLabel?
    @IBOutlet weak var addrL : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(hexString: Color.gray_f4)
        
        self.idenL?.textAlignment = .center
        self.idenL?.edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        self.idenL?.text = "Test Token".localized()
    }
    
    override func reloadData(data: Any) {
        if let wallet = data as? WalletInterface {
            self.nameL?.text = wallet.name
            self.addrL?.text = wallet.address
            
            if wallet.identify == .NCH {
                self.idenL?.isHidden = false
            } else {
                self.idenL?.isHidden = true
            }
        }
    }
}
