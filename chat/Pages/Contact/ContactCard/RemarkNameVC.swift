//
//  RemarkNameVC.swift
//  chat
//
//  Created by Grand on 2019/9/25.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class RemarkNameVC: BaseViewController {
    
    @IBOutlet weak var sureBtn: UIButton?
    @IBOutlet weak var inputTF: UITextField?
    @IBOutlet weak var maskView: UIView?
    
    var disbag = DisposeBag()
    var contact: CPContact? = nil
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            // Fallback on earlier versions
        }
        
        super.viewDidLoad()
        configUI()
        configEvent()
        fillData()
    }
    
    func fillData() {
        if let name = contact?.remark {
            inputTF?.text = name
            inputTF?.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func configUI() {
        self.sureBtn?.setShadow(color: UIColor(hexString: Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20,opacity: 0.3)
    }
    
    func configEvent() {
        
        ///Input
        inputTF?.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
                self?.maskView?.backgroundColor = UIColor(hexString: Color.mask_bottom_fill)
            } else {
                self?.maskView?.backgroundColor = UIColor(hexString: Color.mask_bottom_empty)
            }
        }.disposed(by: disbag)
        
        // change
        self.sureBtn?.rx.tap.subscribe(onNext: { [weak self] in
            let r = self?.checkInputAvalid()
            if r?.result == false {
                Toast.show(msg: r?.msg ?? "", position: .center)
            }
            else {
                if let remark = self?.inputTF?.text, let contact = self?.contact, remark != contact.remark {
                    CPContactHelper.updateRemark(remark, whereContactUser: contact.publicKey, callback: {  (r, msg) in
                        if r == false {
                            Toast.show(msg: msg, position: .center)
                        }
                        else {
                            contact.remark = remark
                            Router.dismissVC()
                            NotificationCenter.post(name: NoticeNameKey.contactRemarkChange,object: contact)
                        }
                    })
                }
                else {
                    Router.dismissVC()
                }
            }
        }).disposed(by: disbag)
    }
    
    
    func checkInputAvalid() -> (result:Bool,msg:String) {
        guard Config.Account.checkRemarkInput(remark: inputTF?.text) else {
            return (false,"Contact_invalid_remark".localized())
        }
        return (true, "valid data".localized())
    }
    
}
