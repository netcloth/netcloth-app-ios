//
//  TokenTransferVC.swift
//  chat
//
//  Created by Grand on 2020/4/23.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit
import BigInt

class TokenTransferVC: BaseViewController {
    
    /// basic
    @IBOutlet weak var iconImgV: UIImageView?
    @IBOutlet weak var balanceTipL: UILabel?
    @IBOutlet weak var balanceL: UILabel?
    @IBOutlet weak var symbolL: UILabel?
    
    /// transfer amount
    @IBOutlet weak var transferAmountTF: UITextField?
    @IBOutlet weak var transferAllBtn: UIButton?
    @IBOutlet weak var transferOverL: UILabel?
    /// recieve addr
    @IBOutlet weak var recieveAddrTF: UITextField?
    @IBOutlet weak var scanBtn: UIButton?
    @IBOutlet weak var addrErrorL: UILabel?
    
    /// Note
    @IBOutlet weak var noteTF: UITextField?
    
    /// Fee
    @IBOutlet weak var feePriceUSD_L: UILabel?
    @IBOutlet weak var feeDetailBtn: UIButton?
    
    /// -- detail
    @IBOutlet weak var speedSlider: UISlider?
    @IBOutlet weak var feeToSymbolL: UILabel?
    
    @IBOutlet weak var  highLevelSwitch: NCNextSwitch?
    
    @IBOutlet weak var gasLimitL: UILabel?
    @IBOutlet weak var gasPriceL: UILabel?
    
    @IBOutlet weak var feeDetailV: UIView?
    @IBOutlet weak var feeDetailV_Height: NSLayoutConstraint?
    
    @IBOutlet weak var nextBtn: NCNextButton?
    
    //MARK:- Life Cycle
    var token: TokenInterface? //must set
    
    var wantAddr: String?
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        self.token?.fetchBalance()
    }
    
    func configUI() {
        let symbol = (self.token?.symbol ?? "")
        self.title = symbol + "trand_Send".localized()
        
        /// top
        if let img = self.token?.wallet.logo {
            self.iconImgV?.image = img
            //            if let color = img.color(at: CGPoint(x: 1, y: img.size.height / 2)) {
            //                self.iconImgV?.setShadow(color: color, offset: CGSize(width: 0, height: 2), radius: 7, opacity: 0.3)
            //            }
        }
        
        let bt = symbol + "Balance".localized()
        self.balanceTipL?.text = bt
        
        self.symbolL?.text = symbol
        
        self.token?.balance.subscribe(onNext: { [weak self] (balance) in
            let decimals = self?.token?.decimals ?? 12
            let bstr = balance.toDecimalBalance(bydecimals: decimals)
            self?.balanceL?.text = bstr
        }).disposed(by: self.disbag)
        
        /// fee
        self.feePriceUSD_L?.text = "\(self.feeAmount())" + symbol
        
        if let addr = wantAddr {
            self.recieveAddrTF?.text = addr
        }
    }
    
    func configEvent() {
        /// transfer
        transferAllBtn?.rx.tap.subscribe(onNext: { [weak self] in
            let balance = self?.balanceL?.text ?? "0"
            let fee = "\(self?.feeAmount() ?? 0)"
            let remaind = balance.toDecimalNumber().subtracting(fee.toDecimalNumber())
            self?.transferAmountTF?.text = remaind.description
        }).disposed(by: disbag)
        
        transferAmountTF?.rx.value.skip(1).subscribe(onNext: { [weak self] (str) in
            
            let b = self?.balanceL?.text ?? ""
            var blen:Int = 1
            let bint = Int(Double(b) ?? 0)
            blen = "\(bint)".count
            
            let symlen = self?.token?.decimals ?? 12
            let len = blen + 1 + symlen
            
            let rule = "^\\d+$|^\\d*.\\d{0,\(symlen)}"
            self?.transferAmountTF?.limitLength(by: rule, maxLength: len)
            
            let input = self?.transferAmountTF?.text ?? "0"
            let balance = self?.balanceL?.text ?? "0"
            if (Double(input) ?? 0) + (self?.feeAmount() ?? 0) > (Double(balance) ?? 0) {
                self?.transferOverL?.isHidden = false
            } else {
                self?.transferOverL?.isHidden = true
            }
        }).disposed(by: disbag)
        
        /// recieve
        
        ///Note
        noteTF?.rx.value.subscribe(onNext: { [weak self] (str) in
            self?.noteTF?.limitLength(by: nil, maxLength: 20)
        }).disposed(by: disbag)
        
        /// fee
    }
    
    //MARK:- Action
    @IBAction func onScanQr() {
        
        #if targetEnvironment(simulator)
        Toast.show(msg: "请使用真机测试")
        return
        #endif
        
        Authorize.canOpenCamera(autoAccess: true, result: { (can) in
            if can == false {
                Alert.showSimpleAlert(title: nil,
                                      msg: "Device_camera".localized(),
                                      cancelTitle: nil)
                return
            }
            let vc = WCQRCodeVC()
            vc.callBack = { [weak vc, weak self] (output) in
                /// dismiss photo alert
                vc?.dismiss(animated: false, completion: nil)
                
                let result = InnerHelper.v3_decodeScanInput(str: output)
                guard case .recieveCoin(let address, let type, let chainID) = result else {
                    Toast.show(msg: "System error".localized())
                    return
                }
                
                let cid = self?.token?.wallet.chainID ?? 0
                if chainID != "\(cid)"  {
                    Toast.show(msg: "System error".localized())
                    return
                }
                
                if let svc = self {
                    //remove WCQRCodeVC
                    svc.navigationController?.popToViewController(svc, animated: true)
                    svc.recieveAddrTF?.text = address
                }
            }
            Router.pushViewController(vc: vc)
        })
    }
    
    @IBAction func onNext(_ sender:Any) {
        
        if checkCanNext() == false {
            return
        }
        
        showBubbleToast()
    }
    
    var tmpBubble: BubbleView?
    func showBubbleToast() -> Void {
        
        let fromAddr = self.token?.wallet.address ?? ""
        let toaddr = self.recieveAddrTF?.text ?? ""
        
        let decimals = self.token?.decimals ?? 12
        let amount = self.transferAmountTF?.text?.bui_toBigUInt(decimals: decimals).description ?? ""
        let fee = "\(self.feeAmount())"
        
        guard let token = self.token  else {
            return
        }
        
        let req = TransferRequest(fromAddr: fromAddr,
                                  toAddr: toaddr,
                                  transferAmount: amount,
                                  txFee: fee,
                                  token: token)
        
        let bv = BubbleView.defaultTransferBubble(req)
        self.view.window?.addSubview(bv)
        
        bv.confirmObserver.confirmPwdOK = { [weak self] in
            /// really send
            self?.reallySendTransfer()
        }
        
        bv.confirmObserver.sendResultBack = { [weak self] in
            /// callback
            self?.quickBackPreviousPage()
        }
        
        tmpBubble = bv
        bv.snp.makeConstraints { (maker) in
            maker.left.right.top.equalToSuperview()
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    fileprivate func reallySendTransfer() {
        let addr = self.recieveAddrTF?.text ?? ""
        let decimals = self.token?.decimals ?? 12
        guard let amount = self.transferAmountTF?.text?.bui_toBigUInt(decimals: decimals).description else {
            Toast.show(msg: "System error".localized())
            return
        }
        let memo = self.noteTF?.text ?? ""
        
        let ro = ResultObserver()
        /// 普通结果监听
        Router.rootWindow?.makeToastActivity(.center)
        ro.transferCallBack = { [weak self] (r, txhash) in
            Router.rootWindow?.hideToastActivity()
            if r == false {
                Toast.show(msg: "System error".localized())
            }
            else {
                self?.tmpBubble?.onSendedTransferReq()
            }
        }
        
        ro.transferQuryTxHashCallBack = { [weak self] (r, txhash) in
            self?.dismissLoading()
            self?.refreshPreviousPage()
        }
        
        self.token?.transferTo(address: addr, amount: amount, memo: memo, callback: ro)
    }
    
    //MARK:- Call back
    func quickBackPreviousPage() {
        
        if let vcs = self.navigationController?.viewControllers {
            for item in vcs {
                if item is TokenDetailVC {
                    self.navigationController?.popToViewController(item, animated: true)
                }
            }
        }
    }
    
    func refreshPreviousPage() {
        if let vcs = self.navigationController?.viewControllers {
            for item in vcs {
                if item is TokenDetailVC {
                    
                }
            }
        }
    }
    
    //MARK:- Helper
    fileprivate func checkCanNext() -> Bool {
        
        let input = self.transferAmountTF?.text ?? "0"
        let balance = self.balanceL?.text ?? "0"
        
        if (Double(input) ?? 0) + feeAmount()  > (Double(balance) ?? 0) ||
            (Double(input) ?? 0) <= 0 {
            Toast.show(msg: "Please input valid amount".localized())
            return false
        }
        
        /// addr
        let addr = self.recieveAddrTF?.text ?? ""
        guard self.token?.isValidAddress(addr: addr) == true else {
            Toast.show(msg: "Please input valid address".localized())
            return false
        }
        
        return true
    }
    
    fileprivate func feeAmount() -> Double {
        /// 200000 * 1000 / 10^12
        return 0.0002
    }
}
