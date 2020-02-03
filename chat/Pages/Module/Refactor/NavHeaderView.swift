  
  
  
  
  
  
  

import UIKit

class NavHeaderView: UIView {
    
    @IBOutlet weak var searchBtn: UIButton?
    @IBOutlet weak var addMoreBtn: UIButton?
    
    var onSearchAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configEvent()
    }
    
    func configEvent() {
        searchBtn?.addTarget(self, action: #selector(tapSearch), for: .touchUpInside)
        
        addMoreBtn?.addTarget(self, action: #selector(tapMore), for: .touchUpInside)
    }
    
      
    
    @objc private func tapSearch() {
        self.onSearchAction?()
    }
    @objc private func tapMore() {
          
        let menuCreate =  YCXMenuItem("New Group Chat".localized(), image: UIImage(named: "create_group_icon")!, target: self, action: #selector(toCreateGroupPage))
        menuCreate?.foreColor = (UIColor(hexString: "#303133"))!
        menuCreate?.titleFont = UIFont.systemFont(ofSize: 16)
        menuCreate?.alignment = .left
        
        let menuAddContacts =  YCXMenuItem("Add Contacts".localized(), image: UIImage(named: "add_contact_icon")!, target: self, action: #selector(toAddContactPage))
        menuAddContacts?.foreColor = (UIColor(hexString: "#303133"))!
        menuAddContacts?.titleFont = UIFont.systemFont(ofSize: 16)
        menuAddContacts?.alignment = .left
        
        let menuScan =  YCXMenuItem("Scan".localized(), image: UIImage(named: "scan_black")!, target: self, action: #selector(toScanContactPage))
        menuScan?.foreColor = (UIColor(hexString: "#303133"))!
        menuScan?.titleFont = UIFont.systemFont(ofSize: 16)
        menuScan?.alignment = .left
        
        YCXMenu.setTintColor(UIColor.white)
        YCXMenu.setSelectedColor(UIColor.clear)
        
        var rect = self.addMoreBtn?.superview?.convert((self.addMoreBtn?.frame)!, to: self.window)
          
        rect?.size.width -= 15
        rect?.origin.y += 13
        YCXMenu.show(in: self.window, from: rect!, menuItems: [menuCreate!,menuAddContacts!, menuScan!]) { (index, item) in
            
        }
    }
    
      
    
    
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
                    vc?.dismiss(animated: false, completion: nil)
                    
                    let v2 = InnerHelper.v2_decodeScanInput(str: output, wantType: "contact")
                    if v2.valid {
                        let publickey = v2.data as? String  ?? ""
                        if v2.type == SessionType.P2P {
                              
                            let iden = R.className(of: ContactAddVC.self) ?? ""
                            if let addVc = R.loadSB(name: "Contact", iden: iden) as? ContactAddVC {
                                addVc.wantAddPublicKey = publickey
                                addVc.wantRemark = v2.minorData as? String
                                Router.pushViewController(vc: addVc)
                            }
                        }
                        else if v2.type == SessionType.group {
                              
                            if let vc = R.loadSB(name: "GroupInviteDetailVC", iden: "GroupInviteDetailVC") as?  GroupInviteDetailVC {
                                vc.qr_groupPublickKey = publickey
                                Router.pushViewController(vc: vc)
                            }
                        }
                    }
                    else {
                        Toast.show(msg: "System error".localized())
                    }
                    
                      
                    withUnsafeMutablePointer(to: &vc!.navigationController!.viewControllers, { (v) in
                        v.pointee.removeSubrange((v.pointee.count - 2 ..< v.pointee.count - 1))
                    })
                }
                Router.pushViewController(vc: vc)
            }
            else {
                Alert.showSimpleAlert(title: nil, msg: NSLocalizedString("Device_camera", comment: ""), cancelTitle: nil)
            }
        })
    }
    
    
    
}
