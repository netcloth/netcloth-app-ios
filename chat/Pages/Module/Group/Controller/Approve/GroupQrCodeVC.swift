







import UIKit
import Photos

class GroupQrCodeVC: BaseViewController {

    @IBOutlet weak var qrcodeImageV: UIImageView?
    @IBOutlet weak var saveButton: UIButton?
    
    @IBOutlet weak var scrollView: UIScrollView?
    
    @IBOutlet weak var showControl: UIControl?
    @IBOutlet weak var accountNameL: UILabel?
    
    @IBOutlet weak var disableContainer: UIView?
    
    let disbag = DisposeBag()
    var groupContact: CPContact?
    
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
        
        guard let contact = self.groupContact else {
            return
        }
        DispatchQueue.global().async {
            let json = InnerHelper.v2_toString(contact: contact) ?? ""
            QrCodeVC.generateQRCode(data: json) { (img) in
                self.qrcodeImageV?.image = img
            }
        }
        
        self.scrollView?.adjustOffset()
        self.saveButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.accountNameL?.text = "\((self.accountNameL?.text)!)\(contact.remark)"
        
        
        let inviteType = self.roomService?.chatContact?.value.inviteType
        if inviteType == CPGroupInviteType.onlyOwner.rawValue {
            self.disableContainer?.isHidden = false
        }
        else {
            self.disableContainer?.isHidden = true
        }

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
        guard let contact = self.groupContact else {
            return
        }
        Authorize.canOpenPhotoAlbum(autoAccess: true, result: {[weak self] (r) in
            if r == true, self?.qrcodeImageV?.image != nil {
                let aname = contact.remark
                
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
                Toast.show(msg: NSLocalizedString("Device_photos", comment: ""))
            }
        })
    }
    
    func toShowBigView() {
        guard let contact = self.groupContact else {
            return
        }
        let aname = contact.remark
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
}
