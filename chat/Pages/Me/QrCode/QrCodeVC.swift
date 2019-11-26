







import Foundation
import Photos

class QrCodeVC: BaseViewController {
    @IBOutlet weak var qrcodeImageV: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var showControl: UIControl!
    
    
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
    }
    
    


    static func generateQRCode(data: String,
                               logo: String = "share_logo",
                               size:Float = 750,
                               ratio:Float = 0.2,
                               complete: ((_ qrcode: UIImage?) -> Void)? ) {
        
        DispatchQueue.global().async {
            
            let sharelogo = UIImage(named: logo)
            let qrImg: UIImage? = SGQRCodeObtain.generateQRCode(withData: data,
                                                  size: CGFloat(size),
                                                  logoImage: sharelogo,
                                                  ratio: CGFloat(ratio),
                                                  logoImageCornerRadius: 0,
                                                  logoImageBorderWidth: 0,
                                                  logoImageBorderColor: nil);
            
            DispatchQueue.main.async {
                complete?(qrImg)
            }
        }
    }
    

    static func coverImage(_ img: UIImage) -> UIImage? {
        guard let ci = img.ciImage else { return img }
        
        let cicontext = CIContext.init()
        guard let cgimg = cicontext.createCGImage(ci, from: (ci.extent)) else { return nil }
        
        return UIImage(cgImage: cgimg)
    }
    

    
    func configUI() {
        
        self.setCustomTitle("QR Code".localized(), color: UIColor.white)
        
        let sh = YYScreenSize().height
        if sh <= 736 {
            self.imageTop.constant = -78
        }
        
        if let _key = CPAccountHelper.loginUser()?.publicKey {
            let name = CPAccountHelper.loginUser()?.accountName ?? "nickname"
            let json = InnerHelper.toContactString(pubkey: _key, alias: name) ?? _key
            QrCodeVC.generateQRCode(data: json) { (img) in
                self.qrcodeImageV.image = img
            }
        }
    }
    
    func configEvent() {
        

        saveButton.rx.tap.subscribe(onNext: { () in
            Authorize.canOpenPhotoAlbum(autoAccess: true, result: {[weak self] (r) in
                if r == true, self?.qrcodeImageV.image != nil {
                    guard let image = QrCodeVC.coverImage((self?.qrcodeImageV.image)!) else {return}
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }, completionHandler: { (r, err) in
                        if r {
                            DispatchQueue.main.async {
                                Toast.show(msg: NSLocalizedString("QR Code Saved", comment: ""));
                            }
                        }
                    })
                }
                else if r == false {
                    Toast.show(msg: NSLocalizedString("Device_photos", comment: ""))
                }
            })
        }).disposed(by: disbag)
        

        showControl.rx.controlEvent(UIControl.Event.touchUpInside).subscribe(onNext: { [weak self] in
            guard let img = self?.qrcodeImageV.image else {
                return
            }
            let qr = QRPhotoImgView(image: img)
            Router.showAlert(view: qr)
        }).disposed(by: disbag)
    }

}



class QRPhotoImgView: UIImageView, NCAlertInterface {
    
    func ncSize() -> CGSize {
        return CGSize(width: YYScreenSize().width, height: YYScreenSize().width)
    }
    
    func ncAutoDismiss() -> Bool {
        return true
    }
    
    func ncBgColor() -> UIColor {
        return UIColor.white
    }
}
