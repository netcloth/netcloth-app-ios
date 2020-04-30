







import UIKit
import Photos

class ShareFriendsVC: BaseViewController {
    
    @IBOutlet weak var qrcodeImageV: UIImageView?
    @IBOutlet weak var saveButton: UIButton?
    
    @IBOutlet weak var showControl: UIControl?
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var contentV: UIView?
    
    @IBOutlet weak var remarkL: UILabel?
    @IBOutlet weak var smallL: UILabel?
    
    let disbag = DisposeBag()
    
    var qrCodeRenderOk: (() ->Void)?
    var contactToBeShare: CPContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.top
        configUI()
        configEvent()
    }
    
    fileprivate func shareToSystem() {
        _ = createShareAppImage().observeOn(MainScheduler.instance).subscribe(onNext: { (image) in
            if let img = image {
                
                let activateVc = UIActivityViewController(activityItems: [img], applicationActivities: nil)
                Router.present(vc: activateVc)
            }
        })
        
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
    
    
    func configUI() {
        
        if contactToBeShare == nil {
            contactToBeShare = CPAccountHelper.loginUser()?.asContact()
        }
        
        let name = contactToBeShare?.remark ?? ""
        if let _key = contactToBeShare?.publicKey,
            let ct = contactToBeShare {
            let json = InnerHelper.v2_toString(contact: ct) ?? _key
            QrCodeVC.generateQRCode(data: json) { (img) in
                self.qrcodeImageV?.image = img
                self.qrCodeRenderOk?()
                if self.qrCodeRenderOk == nil &&
                    self.view.isHidden == false {
                    self.shareToSystem()
                }
            }
        }
        
        self.scrollView?.adjustOffset()
        
        smallL?.text = name.getSmallRemark()
        remarkL?.text = name
        
        let color = contactToBeShare?.publicKey.randomColor() ?? RelateDefaultColor
        smallL?.backgroundColor = UIColor(hexString: color)
    }
    
    func configEvent() {
        
        
        saveButton?.rx.tap.subscribe(onNext: { [weak self] in
            self?.shareToSystem()
        }).disposed(by: disbag)
        
        
        showControl?.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            self?.toShowBigView()
        }).disposed(by: disbag)
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
        return  ShareFriendsVC.createShareAppImage(withContact: self.contactToBeShare)
    }
    
    
    static func createShareAppImage(withContact: CPContact?) -> Observable<UIImage?> {
        
        return Observable.create {  (observer) -> Disposable in
            
            if withContact == nil {
                observer.onCompleted()
            }
            else {
                if let vc = R.loadSB(name: "ShareFriendsVC", iden: "ShareMeQrCodeSave") as? ShareFriendsVC {
                    
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
                    
                    vc.contactToBeShare = withContact
                    Router.rootWindow?.addSubview(vc.view)
                    vc.view.isHidden = true
                     
                    
                    vc.view.frame = Router.rootWindow?.bounds ?? CGRect.zero
                    vc.view.layoutIfNeeded()
                }
                else {
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

}
