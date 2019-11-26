







import UIKit


@objc protocol MoreInputViewDelegate: NSObjectProtocol {

    func onSelectedPicture(image: UIImage?)
}

class MoreInputView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @objc weak var delegate: MoreInputViewDelegate? = nil
    
    @IBOutlet weak var albumBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    let disbag = DisposeBag()
    
    override var intrinsicContentSize: CGSize {
        var h = 180
        if #available(iOS 11.0, *) {
            h += Int(Router.currentViewOfVC?.safeAreaInsets.bottom ?? 0)
        } else {

        }
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(h))
    }
    
    
    deinit {
        print("dealloc \(type(of: self))")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
        configEvent()
    }
    
    func configUI() {
    }
    
    func configEvent() {
        self.albumBtn.rx.tap.subscribe(onNext: { [weak self] in
            
            Authorize.canOpenPhotoAlbum(autoAccess: true, result: { (can) in
                if (can) {
                    self?.showPickerWithType(.photoLibrary)
                }
                else {
                    Toast.show(msg: "Device_photos".localized())
                }
            })
            
        }).disposed(by: disbag)
        
        
        self.cameraBtn.rx.tap.subscribe(onNext: { [weak self] in
            
            Authorize.canOpenCamera(autoAccess: true, result: { (can) in
                if (can) {
                    self?.showPickerWithType(.camera)
                }
                else {
                    Toast.show(msg: "Device_camera".localized())
                }
            })
            
        }).disposed(by: disbag)
    }
    
    func showPickerWithType(_ type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return
        }
        let imgpicker = UIImagePickerController()
        imgpicker.sourceType = type
        imgpicker.delegate = self
        Router.present(vc: imgpicker)
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.global().async {
            var tosend: UIImage?
            if let source = info[.originalImage] as? UIImage {
                tosend = source
            }
            if let edit = info[.editedImage] as? UIImage {
                tosend = edit
            }
            DispatchQueue.main.async {
                self.delegate?.onSelectedPicture(image: tosend)
            }
        }
    }
}
