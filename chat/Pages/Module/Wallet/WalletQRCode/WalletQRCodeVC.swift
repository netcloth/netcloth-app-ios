//
//  WalletQRCodeVC.swift
//  chat
//
//  Created by Grand on 2020/4/28.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit
import Photos

class WalletQRCodeVC: BaseViewController {
    /// News
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var contentV: UIView?

    @IBOutlet weak var logoImgV: UIImageView?
    @IBOutlet weak var qrcodeImageV: UIImageView?
    @IBOutlet weak var showControl: UIControl?

    @IBOutlet weak var tipL: UILabel?
    @IBOutlet weak var addrL: UILabel?
    
    @IBOutlet weak var copyBtn: UIButton?
    @IBOutlet weak var saveButton: UIButton?
    
    let disbag = DisposeBag()
    
    var qrCodeRenderOk: (() ->Void)?
    
    var wallet: WalletInterface?
    var pageTag: Int = 0 // 0 index, 1 share
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.top
        configUI()
        configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearStyle()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes =
                   [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor(hexString: Color.black)]
    }
    
    //MARK:- Public
    func configUI() {
        self.title = (self.wallet?.name ?? "") + (Bundle.is_zh_Hans() ? "": " ") + "Address".localized()
        if pageTag == 0 {
            self.contentV?.fakesetLayerCornerRadiusAndShadow(10,
                                                             color: UIColor(hexString: "#202D47")!,
                                                             offset: CGSize(width: 0, height: 4),
                                                             radius: 13,
                                                             opacity: 0.1)
        }
        
        let addr = self.wallet?.address ?? ""
        addrL?.text = addr
        
        if let json = InnerHelper.v2_toTransferString(addr: addr) {
            var imgname = ""
            if self.pageTag == 1 {
                imgname = "NCH_share_logo"
            }
            
            QrCodeVC.generateQRCode(data: json, logo: imgname) { (img) in
                self.qrcodeImageV?.image = img
                self.qrCodeRenderOk?()
                if self.qrCodeRenderOk == nil &&
                    self.view.isHidden == false {
                    self.shareToSystem()
                }
            }
        }
        
        self.scrollView?.adjustOffset()
    }
    
    func configEvent() {
        
        //save image
        saveButton?.rx.tap.subscribe(onNext: { [weak self] in
            self?.saveImageToLibray()
        }).disposed(by: disbag)
        
        // show big qrcode
        showControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.toShowBigView()
        }).disposed(by: disbag)
        
        /// copy
        copyBtn?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            if let addr = self?.addrL?.text {
                UIPasteboard.general.string = addr
                Toast.show(msg: "Successful copy".localized())
            }
        }).disposed(by: disbag)
    }
    
    //MARK:- Action
    fileprivate func shareToSystem() {
        _ = createShareAppImage().observeOn(MainScheduler.instance).subscribe(onNext: { (image) in
            if let img = image {
                
                let activateVc = UIActivityViewController(activityItems: [img], applicationActivities: nil)
                Router.present(vc: activateVc)
            }
        })
        
    }
    
    func saveImageToLibray() {
        Authorize.canOpenPhotoAlbum(autoAccess: true, result: {[weak self] (r) in
            if r == true, self?.qrcodeImageV?.image != nil {
                
                _ = self?.createShareAppImage().observeOn(MainScheduler.instance).subscribe(onNext: { (image) in
                    if let img = image {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAsset(from: img)
                        }, completionHandler: { (r, err) in
                            if r {
                                DispatchQueue.main.async {
                                    Toast.show(msg: NSLocalizedString("QR Code Saved", comment: ""));
                                }
                            }
                        })
                    }
                })
            }
            else if r == false {
                Toast.show(msg: NSLocalizedString("Device_photos", comment: ""))
            }
        })
    }
    
    func toShowBigView() {
        _ = createShareAppImage().observeOn(MainScheduler.instance).subscribe(onNext: { (image) in
            if let img = image {
                let qr = QRPhotoImgView(image: img)
                qr.contentMode = .scaleAspectFill
                Router.showAlert(view: qr)
            }
        })
    }
    
    func createShareAppImage() -> Observable<UIImage?> {
        return  WalletQRCodeVC.createShareAppImage(wallet: self.wallet)
    }
    
    
    static func createShareAppImage(wallet: WalletInterface?) -> Observable<UIImage?> {
        
        return Observable.create { (observer) -> Disposable in
            
            if let vc = R.loadSB(name: "WalletQRCodeVCSave", iden: "WalletQRCodeVCSave") as? WalletQRCodeVC {
                vc.pageTag = 1
                
                vc.qrCodeRenderOk = { [weak vc] in
                    vc?.contentV?.isOpaque = false
                    if let image = vc?.contentV?.snapshotImage(afterScreenUpdates: true) {
                        observer.onNext(image)
                        observer.onCompleted()
                    }
                    else {
                        observer.onCompleted()
                    }
                    vc?.view.removeFromSuperview()
                }
                
                vc.wallet = wallet
                Router.rootWindow?.addSubview(vc.view)
                vc.view.isHidden = true
                
                vc.view.frame = Router.rootWindow?.bounds ?? CGRect.zero
                vc.view.layoutIfNeeded()
            }
            else {
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

}

