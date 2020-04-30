//
//  SystemMsgCell.swift
//  chat
//
//  Created by Grand on 2019/11/25.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit


/// style center
class SystemMsgCell: ChatCommonCell {
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    @IBOutlet weak var msgContentL: UILabel?
    @IBOutlet weak var createTimeL: UILabel?
    
    @IBOutlet weak var avatarTop: NSLayoutConstraint?
    var isHideTimeL: Bool = true {
        didSet {
            createTimeL?.isHidden = self.isHideTimeL
            self.avatarTop?.constant = self.isHideTimeL ? 10 : 47
        }
    }
    
    var dataMsg: CPMessage?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func reloadData(data: Any) {
        guard let msg = data as? CPMessage else {
            return
        }
        dataMsg = msg
        
        self.isHideTimeL = !msg.showCreateTime
        if msg.showCreateTime {
            self.createTimeL?.text = Time.timeDesc(from: msg.createTime, includeH_M: true)
        }
        
        msgContentL?.text = msg.msgDecodeContent() as? String
    }
    
    //MARK:- Interface
    override func msgContentView() -> UIView? {
        return nil
    }

}
