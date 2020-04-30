//
//  AlertView.swift
//  chat
//
//  Created by Grand on 2019/8/26.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class AlertView: UIView {
    
    var cancelBlock: (() -> Void)?
    var okBlock: (() -> Void)? //if only one, please use this
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var msgLabel: UILabel?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var okButton: UIButton? //if only one, you must use this
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        configUI()
    }
    
    func configUI() {
        self.titleLabel?.textColor = UIColor(hexString: Color.black)
        self.msgLabel?.textColor = UIColor(hexString: Color.gray_62)
        
        self.cancelButton?.setTitleColor(UIColor(hexString: Color.blue), for: UIControl.State.normal)
        self.cancelButton?.backgroundColor = UIColor(rgb: 0x465EFF, alpha: 0.15)
        
        self.okButton?.setTitleColor(UIColor.white, for: UIControl.State.normal)
        self.okButton?.backgroundColor = UIColor(hexString: Color.blue)
        
    }
    
    @IBAction func onOkTap() {
        Router.dismissVC { [weak self] in
            self?.okBlock?()
        }
    }
    
    @IBAction func onCancelTap() {
        Router.dismissVC { [weak self] in
            self?.cancelBlock?()
        }
    }
}

//MARK:- Normal Alert
class NormalAlertView: AlertView, NCAlertInterface {
    
}

//MARK:- One Button Alert
class OneButtonAlert: AlertView, NCAlertInterface {
}

class OneButtonOneMsgAlert: AlertView, NCAlertInterface {
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 150)
    }
}


//MARK:- Input Aert
class NormalInputAlert: AlertView, NCAlertInterface {
    @IBOutlet weak var inputTextField: UITextField?
    
    var checkPreview: (() -> Bool)?
    
    override func onOkTap() {
        if let check = self.checkPreview {
            if check() {
                super.onOkTap()
            }
        } else {
            super.onOkTap()
        }
    }
}

//MARK:-  Error Tip Input Alert
class ErrorTipsInputAlert: NormalInputAlert {
    @IBOutlet weak var checkTipsLabel: UILabel?
    
    var disbag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configEvent()
        checkTipsLabel?.textColor = UIColor(hexString: Color.red)
    }
    
    //event
    func configEvent() {
        inputTextField?.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            } else {
                self?.checkTipsLabel?.isHidden = true
            }
        }.disposed(by: disbag)
    }
}


class RetrySendAlert: AlertView, NCAlertInterface {
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}

//MARK:- Only Msg or Title
class MayEmptyAlertView: AlertView, NCAlertInterface {
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}

//MARK:- Only Msg or Title Or Image
class MayImageAlertView: AlertView, NCAlertInterface {
    
    @IBOutlet weak var imageV: UIImageView?
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}
