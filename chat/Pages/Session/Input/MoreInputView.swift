  
  
  
  
  
  
  

import UIKit
import Photos

@objc protocol MoreInputViewDelegate: NSObjectProtocol {
      
    func onSelectedPicture(image: UIImage?)
    func onSelectedGifData(data: Data?)
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
        DispatchQueue.global().async { [weak self] in
            let type:String = (info[UIImagePickerController.InfoKey.mediaType] as! String)
              
            if type == "public.image" {
                var imgUrl:URL?
                var imageAsset: PHAsset?
                
                var img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage   
                if let editImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    img = editImg
                }
                
                if #available(iOS 11.0, *) {
                    imgUrl = info[UIImagePickerController.InfoKey.referenceURL] as? URL
                    imageAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
                }
                else {
                    imgUrl = info[UIImagePickerController.InfoKey.referenceURL] as? URL
                    if let url = imgUrl {
                        imageAsset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
                    }
                }
                
                if imgUrl?.absoluteString.uppercased().contains("GIF") == true {
                    if let asset = imageAsset {
                        let options = PHImageRequestOptions()
                        options.version = .current
                        options.isSynchronous = true
                        PHImageManager.default().requestImageData(for: asset, options: options) { (data, msg, origin, info) in
                            DispatchQueue.main.async {
                                self?.delegate?.onSelectedGifData(data: data)
                            }
                        }
                    }
                }
                else {
                    if let forsend = img {
                        DispatchQueue.main.async {
                            self?.delegate?.onSelectedPicture(image: forsend)
                        }
                    }
                }
            }
        }
    }
}
