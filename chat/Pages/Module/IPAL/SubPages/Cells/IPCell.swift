//
//  IPCell.swift
//  chat
//
//  Created by Grand on 2019/11/5.
//  Copyright © 2019 netcloth. All rights reserved.
//

import UIKit

class IPCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView?
    @IBOutlet weak var idL: UILabel?
    @IBOutlet weak var nameL: UILabel?
    @IBOutlet weak var delayTimeL: UILabel?
    @IBOutlet weak var evaluationL: UILabel?
    @IBOutlet weak var connectBtn: UIButton?
    
    var pageTag: IPAListVC.PageTag = .C_IPAL
    var disposeBag = DisposeBag()
    override func prepareForReuse() {
          super.prepareForReuse()
          disposeBag = DisposeBag()
      }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container?.fakesetLayerCornerRadiusAndShadow(4,
                                                      color: UIColor(rgb: 0x202D47),
                                                      offset: CGSize(width: 0, height: 2),
                                                      radius: 8,
                                                      opacity: 0.04)
    }
    
    func reloadData(atIndex: Int, data: Any, pageTag: IPAListVC.PageTag) {
        self.pageTag = pageTag
        self.idL?.text = "\(atIndex)."
        self.reloadData(data: data)
    }
    
    override func reloadData(data: Any) {
        guard let node = data as? IPALNode else {
            return
        }
        nameL?.text = node.moniker
        if node.ping > 0 && node.ping < NSNotFound {
            delayTimeL?.text = "\("Latency".localized()): \(node.ping)ms"
        } else {
            delayTimeL?.text = "  "
        }
        
        let (des, color) = node.pingEvaDes
        evaluationL?.text = des
        evaluationL?.textColor = color
        /// Note: Connect status
        if self.pageTag == .C_IPAL {
            _CipalConnectBtn(node: node)
        }
        else if self.pageTag == .A_IPAL {
            _AipalConnectBtn(node: node)
        }
    }
    
    //MARK:- Helper
    fileprivate func _CipalConnectBtn(node: IPALNode) {
        if node.operator_address == IPALManager.shared.store.currentCIpal?.operator_address {
            self.disableConnectBtn()
            self.connectBtn?.setTitle("Connected".localized(), for: .normal)
        }
        else if node.ping == NSNotFound {
            self.disableConnectBtn()
            self.connectBtn?.setTitle("Connect".localized(), for: .normal)
        }
        else {
            self.enableConnectBtn()
            self.connectBtn?.setTitle("Connect".localized(), for: .normal)
        }
    }
    
    fileprivate func _AipalConnectBtn(node: IPALNode) {
        self.delayTimeL?.text = node.details
        self.evaluationL?.isHidden = true
        if node.operator_address == IPALManager.shared.store.curAIPALNode?.operator_address {
            self.disableConnectBtn()
            self.connectBtn?.setTitle("Connected".localized(), for: .normal)
        }
        else {
            self.enableConnectBtn()
            self.connectBtn?.setTitle("Connect".localized(), for: .normal)
        }
    }
    
    
    func disableConnectBtn() {
        self.connectBtn?.isUserInteractionEnabled = false
        self.connectBtn?.backgroundColor = UIColor(hexString: Color.gray_f5)
        self.connectBtn?.layer.borderColor = UIColor(hexString: "#EDEFF2")?.cgColor
        self.connectBtn?.setTitleColor(UIColor(hexString: Color.gray_90), for: .normal)
    }
    
    func enableConnectBtn() {
        self.connectBtn?.isUserInteractionEnabled = true
        self.connectBtn?.backgroundColor = UIColor.white
        self.connectBtn?.layer.borderColor = UIColor(hexString: Color.blue)?.cgColor
        self.connectBtn?.setTitleColor(UIColor(hexString: Color.blue), for: .normal)
    }
}

extension IPALNode {
    var pingEvaDes: (String, UIColor) {
        get {
            let p = self.ping
            if p == 0 {
                return ("testing…".localized(), UIColor(hexString: Color.blue)! )
            }
            else if p > 0 && p <= 200 {
                return ("low".localized(), UIColor(hexString: "#169A41")! )
            }
            else if p > 200 && p <= 500 {
                return ("medium".localized(), UIColor(hexString: "#F5A623")! )
            }
            else if p > 500 && p < NSNotFound {
                return ("high".localized(), UIColor(hexString: "#ED6765")! )
            }
            else {
                return ("unable to connect".localized(), UIColor(hexString: Color.red)! )
            }
        }
    }
}
