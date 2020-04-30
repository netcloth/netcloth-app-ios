//
//  NavHeaderView.swift
//  chat
//
//  Created by Grand on 2019/12/5.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class NavHeaderView: UIView {
    
    @IBOutlet weak var addMoreBtn: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
        configEvent()
    }
    
    func configUI() {
        self.backgroundColor = UIColor(hexString: Color.app_nav_theme)
    }
    
    func configEvent() {
        addMoreBtn?.addTarget(self, action: #selector(tapMore), for: .touchUpInside)
    }
    
    //MARK:- Action
    @objc private func tapMore() {
        //set title
        let menuCreate =  YCXMenuItem("New Group Chat".localized(), image: UIImage(named: "create_group_icon")!, target: self, action: #selector(toCreateGroupPage))
        menuCreate?.foreColor = (UIColor(hexString: Color.black))!
        menuCreate?.titleFont = UIFont.systemFont(ofSize: 16)
        menuCreate?.alignment = .left
        
        let menuAddContacts =  YCXMenuItem("Add Contacts".localized(), image: UIImage(named: "add_contact_icon")!, target: self, action: #selector(toAddContactPage))
        menuAddContacts?.foreColor = (UIColor(hexString: Color.black))!
        menuAddContacts?.titleFont = UIFont.systemFont(ofSize: 16)
        menuAddContacts?.alignment = .left
        
        let menuScan =  YCXMenuItem("Scan".localized(), image: UIImage(named: "scan_black")!, target: self, action: #selector(toScanContactPage))
        menuScan?.foreColor = (UIColor(hexString: Color.black))!
        menuScan?.titleFont = UIFont.systemFont(ofSize: 16)
        menuScan?.alignment = .left
        
        YCXMenu.setTintColor(UIColor.white)
        YCXMenu.setSelectedColor(UIColor.clear)
        
        var rect = self.addMoreBtn?.superview?.convert((self.addMoreBtn?.frame)!, to: self.window)
        //magic
        rect?.size.width -= 15
        rect?.origin.y += 13
        YCXMenu.show(in: self.window, from: rect!, menuItems: [menuCreate!,menuAddContacts!, menuScan!]) { (index, item) in
            
        }
    }
    
    //MARK:- <#[注释]#>
    
    
    @objc func toCreateGroupPage() {
        if let vc = R.loadSB(name: "GroupCreate", iden: "GroupNameInputVC") as? GroupNameInputVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    @objc func toAddContactPage() {
        if let vc = R.loadSB(name: "Contact", iden: "ContactAddVC") as? ContactAddVC {
            Router.pushViewController(vc: vc)
        }
    }
    
    
    @objc func toScanContactPage() {
        #if targetEnvironment(simulator)
        Toast.show(msg: "请使用真机测试")
        return
        #endif
        
        Authorize.canOpenCamera(autoAccess: true, result: { (can) in
            if (can) {
                let vc = WCQRCodeVC()
                vc.callBack = { [weak vc] (output) in
                    /// dismiss photo alert
                    vc?.dismiss(animated: false, completion: nil)
                    
                    let result = InnerHelper.v3_decodeScanInput(str: output)
                    
                    if InnerHelper.handleDecodeContact(vc: vc!, result: result) {
                    }
                    else if InnerHelper.handleDecodeRecieveCoin(vc: vc!, result: result) {
                    }
                    else {
                        Toast.show(msg: "System error".localized())
                    }
                }
                Router.pushViewController(vc: vc)
            }
            else {
                Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Device_camera", comment: ""), cancelTitle: nil)
            }
        })
    }
}
