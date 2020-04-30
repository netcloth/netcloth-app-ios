//
//  TokenTransferConfirmVC.swift
//  chat
//
//  Created by Grand on 2020/4/23.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit

class TokenTransferConfirmVC: BaseViewController {
    
    @IBOutlet weak var balanceL: UILabel?
    @IBOutlet weak var symbolL: UILabel?
    
    @IBOutlet weak var fromAddr: UILabel?
    @IBOutlet weak var toAddr: UILabel?
    @IBOutlet weak var feeTotal: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
    }
    
    func configUI() {
        
        let req = self.bubbleView?.transferRequest
        
        let decimal = req?.token.decimals ?? 12
        self.balanceL?.text = req?.transferAmount.toDecimalBalance(bydecimals: decimal)
        
        let symbol = req?.token.symbol ?? ""
        self.symbolL?.text = symbol
        
        fromAddr?.text = req?.fromAddr
        toAddr?.text = req?.toAddr
        feeTotal?.text = (req?.txFee ?? "") + " \(symbol)"
    }
    
    
    @IBAction func onNext() {
        if let vc = R.loadSB(name: "TokenPwdInputVC", iden: "TokenPwdInputVC") as? TokenPwdInputVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
