//
//  ImportAccountContainerVC.swift
//  chat
//
//  Created by Grand on 2019/9/12.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit
import WMPageController
import IQKeyboardManagerSwift

class ImportAccountContainerVC: WMPageController {
    deinit {
        print("\(type(of: self))")
    }
    
    @IBOutlet weak var serviceBtn: UIButton?
    @IBOutlet weak var privacyBtn: UIButton?
    @IBOutlet var proxyVs: [UIView]!
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = false
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        self.configUI()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
        
        configEvent()
    }
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         for item in proxyVs {
             self.view.bringSubviewToFront(item)
         }
     }
    
    func configUI() {
        self.menuView?.layoutMode = .center
        self.menuItemWidth = YYScreenSize().width / 2
        self.menuView?.backgroundColor = UIColor(hexString: "#F7F8FA")
        
        self.titleColorSelected = UIColor(hexString: Color.blue)!
        self.titleColorNormal = UIColor(hexString: Color.gray_90)!
        
        self.reloadData()
    }
    
    func configEvent() {
        serviceBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let url = URL(string: Config.NetOfficial.ServiceUrl) {
                UIApplication.shared.openURL(url)
            }
        }).disposed(by: disbag)
        
        privacyBtn?.rx.tap.subscribe(onNext: { [weak self] in
            if let url = URL(string: Config.NetOfficial.PrivacyUrl) {
                UIApplication.shared.openURL(url)
            }
        }).disposed(by: disbag)
    }
    
    //MARK: Delegate
    override func numbersOfChildControllers(in pageController: WMPageController) -> Int {
        return 2
    }
    
    override func pageController(_ pageController: WMPageController, viewControllerAt index: Int) -> UIViewController {
        if index == 0 {
            let vc = R.loadSB(name: "Import", iden: "ImportKeystoreVC")
            return vc
        }
        else {
            let vc = R.loadSB(name: "Import", iden: "ImportPrivateKeyVC")
            return vc
        }
    }
    
    override func pageController(_ pageController: WMPageController, titleAt index: Int) -> String {
        if index == 0 {
            return "Keystore"
        }
        else {
            return "Private Key".localized()
        }
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameFor menuView: WMMenuView) -> CGRect {
        let top = self.navigationController?.navigationBar.frame.maxY ?? 0
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: 48)
    }
    
    override func pageController(_ pageController: WMPageController, preferredFrameForContentView contentView: WMScrollView) -> CGRect {
        let top = (self.navigationController?.navigationBar.frame.maxY ?? 0 ) + 48
        return CGRect(x: 0, y: top, width: YYScreenSize().width, height: YYScreenSize().height - top)
    }
}
