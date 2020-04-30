//
//  IPAListHeaderView.swift
//  chat
//
//  Created by Grand on 2020/3/15.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class IPAListHeaderView: UIView {
    
    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var tipLabel: UILabel?
    
    @IBOutlet weak var containerV : UIView?
    @IBOutlet weak var bgImageV : UIImageView?
    
    @IBOutlet weak var nameL : UILabel?
    @IBOutlet weak var statusL : UILabel?
    @IBOutlet weak var historyBtn : UIButton?
    
    deinit {
        print("dealloc \(type(of: self))")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectChange), name: NSNotification.Name.serviceConnectStatusChange, object: nil)
    }
    
    func vcViewDidLoad() {
        if let tag = getType() {
            if tag == .C_IPAL {
                self.tipLabel?.text = "Claimed Communication Server".localized()
            }
            else if tag == .A_IPAL {
                self.tipLabel?.text = "Claimed Application Server".localized()
            }
        }
        else {
            assert(false, "error vc")
        }
    }
    
    //MARK:- Reload
    func reloadData(_ data: IPALNode?) {
        nameL?.text = data?.moniker
        handleConnectChange()
    }
    
    @objc func handleConnectChange() {
        if let tag = getType() {
            if tag == .C_IPAL {
                _c_handleConnectChange()
            }
            else if tag == .A_IPAL {
                _a_handleConnectChange()
            }
        }
        else {
            assert(false, "error vc")
        }
    }
    
    fileprivate func _c_handleConnectChange() {
        let isClaimOk = IPALManager.shared.store.currentCIpal?.isClaimOk == 1
        let isClaimFail = IPALManager.shared.store.currentCIpal?.isClaimOk == 2
        
        if CPAccountHelper.isConnected() && isClaimOk {
            self.statusL?.text = "ipal_connect_ok".localized()
            self.bgImageV?.image = UIImage(named: "ipal_connect_ok_bg")
        } else {
            if CPAccountHelper.isNetworkOk() && !isClaimFail {
                self.statusL?.text = "ipal_connect_ing".localized()
                self.bgImageV?.image = UIImage(named: "ipal_connect_ing_bg")
            } else {
                self.statusL?.text = "ipal_connect_fail".localized()
                self.bgImageV?.image = UIImage(named: "ipal_connect_fail_bg")
            }
        }
    }
    
    fileprivate func _a_handleConnectChange() {
        
        if let node =  IPALManager.shared.store.curAIPALNode {
            self.statusL?.text = "ipal_connect_ok".localized()
            self.bgImageV?.image = UIImage(named: "ipal_connect_ok_bg")
        }
        else {
            self.statusL?.text = "ipal_connect_fail".localized()
            self.bgImageV?.image = UIImage(named: "ipal_connect_fail_bg")
        }
    }
    
    fileprivate func  getType() -> IPAListVC.PageTag? {
        if let vc = self.viewController as? IPAListVC {
            return vc.fromSource
        }
        return nil
    }
}

class HeaderContainerView: UIView {
    @IBOutlet weak var header: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil {
            var array = self.header?.allSubViews ?? []
            array = array.filter { (v) -> Bool in
                return v is UIButton
            }
            
            for subview in array {
                let subPoint = subview.convert(point, from: self)
                if subview.bounds.contains(subPoint) {
                    return subview
                }
            }
        }
        return view
    }
}
