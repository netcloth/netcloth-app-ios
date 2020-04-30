//
//  WalletDetailVC.swift
//  chat
//
//  Created by Grand on 2020/4/14.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit
import swift_cli

/// 总资产 和 token 预览
class WalletDetailVC: BaseViewController,
UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var tipL: UILabel?
    
    @IBOutlet weak var nameL : UILabel?
    @IBOutlet weak var idenL : PaddingLabel?
    @IBOutlet weak var addrL : UILabel?
    
    /// 资产
    @IBOutlet weak var assetsL : UILabel?
    @IBOutlet weak var totalPrice : UILabel?
    @IBOutlet weak var eyeBtn : UIButton?
    @IBOutlet weak var moreBtn : UIButton?
    
    ///
    @IBOutlet weak var tableView : UITableView?
    
    @IBOutlet weak var qrBtn : UIButton?

    let disbag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configEvent()
        fillDataUI()
        
        self.wallet?.fetchTotalBalance()
        self.tableView?.reloadData()
    }
    
    //MARK:-
    var wallet: WalletInterface? {
        return self.vcInitData as? WalletInterface
    }
    
    fileprivate func configUI() {
        reset()
        
        self.tableView?.adjustHeader()
        self.tableView?.adjustFooter()
        
        self.tableView?.adjustOffset()
        self.tableView?.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        guard let wallet = self.vcInitData as? WalletInterface else {
            return
        }
        
        self.title = wallet.name
        
        if wallet.identify == .NCH {
            tipL?.text = "NCH_TEST_TIP".localized()
            idenL?.textAlignment = .center
            idenL?.edgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
            idenL?.text = "Test Token".localized()
            idenL?.isHidden = false
        }
        else {
            tipL?.text = "Wallet_TIP".localized()
            idenL?.isHidden = true
        }
        
        nameL?.text = wallet.name
        addrL?.text = wallet.address
        
        totalPrice?.text = "0.00"
    }
    
    fileprivate func configEvent() {
        
        eyeBtn?.rx.tap.subscribe(onNext: { [weak self] in
            let show = !(NCUserCenter.shared?.walletManage.value.showPrice ?? true)
            NCUserCenter.shared?.walletManage.change(commit: { (data) in
                data.showPrice = show
            })
        }).disposed(by: disbag)
        
        NCUserCenter.shared?.walletManage.observable.subscribe(onNext: { [weak self] in
            self?.fillDataUI()
        }).disposed(by: disbag)
        
        NCUserCenter.shared?.walletDataStore.observable.subscribe(onNext: { [weak self] in
            self?.fillDataUI()
        }).disposed(by: disbag)
        
        self.wallet?.totalChangeObserver.subscribe(onNext: { [weak self] in
            self?.dismissLoading()
            self?.fillDataUI()
        }).disposed(by: disbag)
    }
    
    fileprivate func reloadTableView() {
        self.tableView?.reloadData()
    }
    
    fileprivate func fillDataUI() {
        let isShow = (NCUserCenter.shared?.walletManage.value.showPrice ?? true)
        if isShow {
            totalPrice?.text = "0.00"
            eyeBtn?.setImage(UIImage(named: "wallet_open_eye"), for: .normal)
        }
        else {
            totalPrice?.text = "****"
            eyeBtn?.setImage(UIImage(named: "wallet_close_eye"), for: .normal)
        }
        
        guard let wallet = self.wallet else {
            return
        }
        nameL?.text = wallet.name
    }
    
    // MARK:-  Action
    func onActionMore() {
        
        guard let wallet = self.vcInitData as? WalletInterface else {
            return
        }
        if let vc = R.loadSB(name: "WalletManageNameVC", iden: "WalletManageNameVC") as? WalletManageNameVC {
            vc.vcInitData = wallet as AnyObject
            Router.pushViewController(vc: vc)
        }
    }
    
    @IBAction func toWalletQrPage() {
        if let vc = R.loadSB(name: "WalletQRCodeVC", iden: "WalletQRCodeVC") as? WalletQRCodeVC {
            vc.wallet = self.wallet
            Router.pushViewController(vc: vc)
        }
    }
    
    @IBAction func updateWalletBalance() {
        showLoading()
        self.wallet?.fetchTotalBalance()
    }
    
    //MARK:-  Helper
    
    fileprivate func reset() {
        tipL?.text = ""
        nameL?.text = ""
        idenL?.isHidden = true
        addrL?.text = ""
        
        totalPrice?.text = ""
        assetsL?.text = "Assets".localized()
    }
    
    //MARK:- TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.wallet?.assetTokens.count ?? 0, 1) //wallet
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WalletDetailCell
        
        if let token = self.wallet?.assetTokens[safe: indexPath.row]  {
            cell.reloadData(data: token)
        }
        else if let wallet = self.wallet {
            cell.reloadData(data: wallet)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            self.wallet?.identify == .NCH,
            let token = self.wallet?.assetTokens[safe: indexPath.row],
            let vc = R.loadSB(name: "TokenDetailVC", iden: "TokenDetailVC") as? TokenDetailVC
            else {
                return
        }
        vc.token = token
        Router.pushViewController(vc: vc)
    }
}
