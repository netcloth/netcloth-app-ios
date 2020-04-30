//
//  ChatCommonCell.swift
//  chat
//
//  Created by Grand on 2019/8/1.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

protocol CommonCellConfirm {
    func onTapCell()
    func msgContentView() -> UIView?
}

@objc protocol ChatCommonCellDelegate {
    @objc optional
    func onTapAvatar(pubkey: String) -> Void
    @objc optional
    func onRetrySendMsg(_ msgId: CLongLong) -> Void
    
    @objc optional
    func onShowBigPhoto(_ img: UIImage, containerView: UIView) -> Void
    
    @objc optional
    func onLongPressAvatar(pubkey: String, senderName: String) -> Void
}

@objc class ChatCommonCell: UITableViewCell, CommonCellConfirm {
    
    //MARK:- property
    @IBOutlet weak var LgroupNick: UILabel?
    @IBOutlet weak var LgroupMasterIden: PaddingLabel?
    weak var delegate: ChatCommonCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(hexString: Color.room_bg)
        self.contentView.backgroundColor = UIColor(hexString: Color.room_bg)
        
        self.LgroupMasterIden?.edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        self.LgroupMasterIden?.text = "Founder".localized()
    }
        
    func onTapCell() {
    }
    
    func msgContentView() -> UIView? {
        return nil
    }
}
