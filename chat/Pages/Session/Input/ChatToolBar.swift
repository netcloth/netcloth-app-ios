







import Foundation

enum ToolBarStatus: Int {
    case text
    case audio
    case emoj
    case more
}


class ChatToolBar:UIView,
UITextFieldDelegate,
EmojKeyBoardViewDelegate,
MoreInputViewDelegate
{
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnRecord: SRAudioRecordButton!
    @IBOutlet weak var switchChannelBtn: UIButton!
    @IBOutlet weak var emojBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var placeHolderBtn: UIButton?
    
    var clearTextAfterSend: Bool = true
    private let disbag = DisposeBag()
    
    lazy var emojKeyboardView: EmojKeyBoardView = {
        let v =  R.loadNib(name: "EmojKeyBoardView") as! EmojKeyBoardView
        v.width = YYScreenSize().width
        v.delegate = self
        return v
    }()
    
    lazy var moreKeyboardView: MoreInputView = {
        let v =  R.loadNib(name: "MoreInputView") as! MoreInputView
        v.width = YYScreenSize().width
        v.delegate = self
        return v
    }()
    

    var status:ToolBarStatus? = .text {
        didSet {
            btnRecord.isHidden = !(status == .audio);
            let channelImg = (status == .audio)
                ? UIImage(named: "键盘")
                : UIImage(named: "编组 2")
            switchChannelBtn.setImage(channelImg, for: .normal)
            textField.isUserInteractionEnabled =  !(status == .audio)
            
            if status == .text {
                textField.inputView = nil
                textField.reloadInputViews()
                textField.becomeFirstResponder()
            }
            else if status == .audio {
                textField.resignFirstResponder()
            }
            else if status == .emoj {
                textField.inputView = self.emojKeyboardView
                textField.reloadInputViews()
                textField.becomeFirstResponder()
            }
            else if status == .more {
                textField.inputView = self.moreKeyboardView
                textField.reloadInputViews()
                textField.becomeFirstResponder()
            }
        }
    }
    

    var publish:PublishSubject = PublishSubject<Any?>()

    deinit {
        publish.onCompleted()
        SRAudioRecorderManager.shared()?.delegate = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
        configEvent()
    }
    

    func configUI() {
        textField.returnKeyType = .send
        textField.delegate = self
        
        SRAudioRecorderManager.shared()?.delegate = self
        SRAudioRecorderManager.shared()?.maxDuration = 60
        SRAudioRecorderManager.shared()?.minDuration = 1
        SRAudioRecorderManager.shared()?.showCountdownPoint = 10
        
    }
    
    func configEvent() {
        
        switchChannelBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let s = self?.status {
                self?.status = (s == .audio) ? .text : .audio;
            }
        }).disposed(by: disbag)
        
        emojBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let s = self?.status {
                self?.status = (s == .emoj) ? .text : .emoj;
            }
        }).disposed(by: disbag)
        
        moreBtn.rx.tap.subscribe(onNext: { [weak self] in
            if let s = self?.status {
                self?.status = (s == .more) ? .text : .more;
            }
        }).disposed(by: disbag)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let t = textField.text
        if t?.isEmpty == true {
            return false
        }
        publish.onNext(textField.text)
        if clearTextAfterSend {
            textField.text = ""
        }
        return false
    }
    
    func resetInBlack(isBlack: Bool) {
        if isBlack {
            self.isUserInteractionEnabled = false
            self.placeHolderBtn?.isHidden = false
            self.placeHolderBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
            self.placeHolderBtn?.setTitle("This contact is in your blacklist.".localized(), for: .normal)
        } else {
            self.isUserInteractionEnabled = true
            self.placeHolderBtn?.isHidden = true
        }
    }
    
    
}


extension ChatToolBar: SRAudioRecorderManagerDelegate {
    
    func audioRecorderManagerDidFinishRecordingFailed() {
        Toast.show(msg: NSLocalizedString("System error", comment: ""))
    }
    
    func audioRecorderManagerAVAuthorizationStatusDenied() {
        Toast.show(msg: NSLocalizedString("Device_microphone", comment: ""),position: .center)
    }
    
    func audioRecorderManagerDidFinishRecordingSuccess(_ audioFilePath: String!) {

        DispatchQueue.global().async {
            if let data = NSData(contentsOfFile: audioFilePath)  {
                DispatchQueue.main.async {
                    self.publish.onNext(data)
                }
            }
        }
    }
}


extension ChatToolBar {
    func onInputEmoj(str: String) {
        self.textField.insertText(str)
    }
    
    func onDeleteInput() {
        self.textField.deleteBackward()
    }
    
    func onSendKeyTap() {

        textFieldShouldReturn(self.textField)
    }
}



extension ChatToolBar {
    func onSelectedPicture(image: UIImage?) {

        DispatchQueue.global().async {
            
            guard let img = image else {
                return
            }
            
            let data = UIImage.lubanCompressImage(img)
            
            DispatchQueue.main.async {
                               let dic = ["image":data]
                               self.publish.onNext(dic)
                           }
        
        }
    }
}


extension UIImage {

    func compressTo(_ expectedSizeInMb:Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue)  {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.25
                }
            }
        }
        
        if let data = imgData {
            return data
        }
        return nil
    }
}

