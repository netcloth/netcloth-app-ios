//
//  IPALDescribeVC.swift
//  chat
//
//  Created by Grand on 2019/11/5.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class IPALIndexVC: BaseViewController {
    
    @IBOutlet weak var cipalContainer: UIView?
    @IBOutlet weak var cipalLabel: UILabel?
    
    @IBOutlet weak var aipalContainer: UIView?
    @IBOutlet weak var aipalLabel: UILabel?
    
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
            // Fallback on earlier versions
        }
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fillData()
    }
    
    
    func configUI() {
                
        cipalContainer?.fakesetLayerCornerRadiusAndShadow( 4,
                                                       color: UIColor(hexString: Color.gray_bf)!,
                                                       offset: CGSize(width: 0, height: 2),
                                                       radius: 7,
                                                       opacity: 0.3)
        aipalContainer?.fakesetLayerCornerRadiusAndShadow( 4,
                                                       color: UIColor(hexString: Color.gray_bf)!,
                                                       offset: CGSize(width: 0, height: 2),
                                                       radius: 7,
                                                       opacity: 0.3)
    }
    
    func fillData() {
        let node = IPALManager.shared.store.currentCIpal
        self.cipalLabel?.text = node?.moniker
        
        let anode = IPALManager.shared.store.curAIPALNode
        self.aipalLabel?.text = anode?.moniker
    }
    
    @IBAction func toC_IPAL() {
        if let vc = R.loadSB(name: "IPALList", iden: "IPAListVC") as? IPAListVC {
            Router.pushViewController(vc: vc)
            vc.fromSource = .C_IPAL
        }
    }
    
    @IBAction func toA_IPAL() {
        if let vc = R.loadSB(name: "IPALList", iden: "IPAListVC") as? IPAListVC {
            Router.pushViewController(vc: vc)
            vc.fromSource = .A_IPAL
        }
    }
    
}
