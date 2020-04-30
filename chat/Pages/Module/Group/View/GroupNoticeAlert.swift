//
//  GroupNoticeAlert.swift
//  chat
//
//  Created by Grand on 2019/12/17.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class GroupNoticeAlert: AlertView , NCAlertInterface {
    
    @IBOutlet weak var recieveImage: UIImageView?
    @IBOutlet weak var recieveControl: UIControl?
    
    @IBOutlet weak var muteImage: UIImageView?
    @IBOutlet weak var muteControl: UIControl?
    
    let disbag =  DisposeBag()
    
    var recieveHandle: (() -> Void)?
    var muteHandle: (() -> Void)?
    func hightlightRecieve(isRec: Bool) {
        recieveImage?.image = isRec ? UIImage(named: "group_select") :  UIImage(named: "group_un_select")
        muteImage?.image = isRec ? UIImage(named: "group_un_select") :  UIImage(named: "group_select")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configEvent()
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 204)
    }
    
    func configEvent() {
        self.recieveControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.recieveHandle?()
            self?.onOkTap()
        }).disposed(by: disbag)
        
        self.muteControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.muteHandle?()
            self?.onOkTap()
        }).disposed(by: disbag)
    }
    
}
