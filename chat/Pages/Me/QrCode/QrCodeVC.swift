







import Foundation
import Photos

class QrCodeVC: BaseViewController {
    
    @IBOutlet weak var qrcodeImageV: UIImageView?
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var shareButton: UIButton?
    
    @IBOutlet weak var showControl: UIControl?
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var accountNameL: UILabel?
    
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.top
        configUI()
        configEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearStyle()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 48/255.0, green: 49/255.0, blue: 51/255.0, alpha: 1)
    }
    
    
    
    func configUI() {
        
        self.title = "QR Code".localized()
        
        if let _key = CPAccountHelper.loginUser()?.publicKey {
            let name = CPAccountHelper.loginUser()?.accountName ?? ""
            let json = InnerHelper.v2_toContactString(pubkey: _key, alias: name) ?? _key
            QrCodeVC.generateQRCode(data: json) { (img) in
                self.qrcodeImageV?.image = img
            }
        }
        
        self.scrollView?.adjustOffset()
        
        self.shareButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        self.saveButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.accountNameL?.text = "\((self.accountNameL?.text)!)\((CPAccountHelper.loginUser()?.accountName)!)"
    }
    
    func configEvent() {
        
        
        saveButton?.rx.tap.subscribe(onNext: { [weak self] in
            self?.saveImageToLibray()
        }).disposed(by: disbag)
        
        
        showControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.toShowBigView()
        }).disposed(by: disbag)
    }
    
    func saveImageToLibray() {
        Authorize.canOpenPhotoAlbum(autoAccess: true, result: {[weak self] (r) in
            if r == true, self?.qrcodeImageV?.image != nil {
                let contact = CPAccountHelper.loginUser()?.asContact()
                _ = QrCodeVC.v2_createShareAppImage(withContact: contact)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (image) in
                        if let img = image {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAsset(from: img)
                            }, completionHandler: { (r, err) in
                                if r {
                                    DispatchQueue.main.async {
                                        Toast.show(msg: "QR Code Saved".localized());
                                    }
                                }
                            })
                        }
                    })
            }
            else if r == false {
                Toast.show(msg: "Device_photos".localized())
            }
        })
    }
    
    func toShowBigView() {
        let contact = CPAccountHelper.loginUser()?.asContact()
        _ = QrCodeVC.v2_createShareAppImage(withContact: contact)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (image) in
                if let img = image {
                    let qr = QRPhotoImgView(image: img)
                    qr.contentMode = .scaleAspectFill
                    Router.showAlert(view: qr)
                }
            })
    }
    
    
    
    static func createBigImage(accountName:String,
                               qrImg: UIImage?,
                               title: String? = nil) -> UIImage? {
        guard
            let bigV: QrBigPhotoView = R.loadNib(name: "QrBigPhotoView") as? QrBigPhotoView,
            let realQrImg = qrImg else {
                return nil
        }
        
        if let t = title {
            bigV.accountNameL?.text = t
        }
        
        bigV.accountNameL?.text = "\((bigV.accountNameL?.text)!)\(accountName)"
        bigV.qrImageV?.image = realQrImg
        bigV.isOpaque = false
        bigV.setNeedsLayout()
        bigV.layoutIfNeeded()
        
        let size =
        bigV.systemLayoutSizeFitting(CGSize(width: 375, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        bigV.width = 375
        bigV.height = size.height
        
        if let image = bigV.snapshotImage(afterScreenUpdates: true) {
           return image.byRoundCornerRadius(10)
        }

        return nil
    }
    
    static func v2_createShareAppImage(withContact: CPContact?) -> Observable<UIImage?> {
        return ShareFriendsVC.createShareAppImage(withContact: withContact)
    }
    
    
    static func generateQRCode(data: String,
                               logo: String = "share_logo",
                               size:Float = 750,
                               ratio:Float = 0.2,
                               complete: ((_ qrcode: UIImage?) -> Void)? ) {
        
        DispatchQueue.global().async {
            
            var qrImg: UIImage?
            if logo.isEmpty {
                 qrImg = SGQRCodeObtain.generateQRCode(withData: data, size: CGFloat(size))
            }
            else {
                let sharelogo = UIImage(named: logo)
                qrImg = SGQRCodeObtain.generateQRCode(withData: data,
                                                      size: CGFloat(size),
                                                      logoImage: sharelogo,
                                                      ratio: CGFloat(ratio),
                                                      logoImageCornerRadius: 0,
                                                      logoImageBorderWidth: 0,
                                                      logoImageBorderColor: nil)
            }
            
            DispatchQueue.main.async {
                complete?(qrImg)
            }
        }
    }
}



class QRPhotoImgView: UIImageView, NCAlertInterface {
    
    func ncSize() -> CGSize {
        let w = YYScreenSize().width - 16
        let h = w * (self.image?.size.height ?? 1) / (self.image?.size.width ?? 1)
        return CGSize(width: w, height: h)
    }
    
    func ncAutoDismiss() -> Bool {
        return true
    }
    
    func ncBgColor() -> UIColor {
        return UIColor(hexString: "#F7F8FA")!
    }
}


extension UIImage {
    func nc_byCornerRadius(_ corner: CGFloat) -> UIImage? {
        let w = self.size.width * self.scale
        let h = self.size.height * self.scale
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: w, height: h), false, 1.0)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: corner)
        path.addClip()
        
        
        self.draw(in: rect)
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret
    }
}
