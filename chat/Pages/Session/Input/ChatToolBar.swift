







import Foundation


protocol KeyboardReturn {
    var autoDismiss: Bool { get set }
}



class ChatToolBar:UIView,
UITextFieldDelegate,
EmojKeyBoardViewDelegate,
MoreInputViewDelegate
{
    
    enum ToolBarStatus: Int {
        case text 
        case audio
        case emoj
        case more
    }
    
    @IBOutlet weak var textField: UITextField! 
    
    @IBOutlet weak var btnRecord: SRAudioRecordButton!
    @IBOutlet weak var placeHolderBtn: UIButton?  
    @IBOutlet weak var resetTextBtn: UIButton?  
    
    @IBOutlet weak var switchChannelBtn: UIButton! 
    @IBOutlet weak var emojBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    
    fileprivate let maxTextLength = 1000
    
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
        
        if self.roomService?.chatContact?.value.sessionType == SessionType.group  {
            v.hideTransfer()
        }
        
        return v
    }()
    
    lazy var innerHelper: OCInnerHelper = {
        let v = OCInnerHelper()
        v.input = self.textField
        return v
    }()
    
    lazy var atCache: InputAtCache = {
        let v = InputAtCache()
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
            
            
            resetTextBtn?.isHidden = !(status == .emoj || status == .more)
            
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
        
        resetTextBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.status = .text
        }).disposed(by: disbag)
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
    
    func resetLock(lock:Bool, lockStr: String?) {
        if lock {
            self.endEditing(true)
            self.isUserInteractionEnabled = false
            self.placeHolderBtn?.isHidden = false
            self.placeHolderBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
            self.placeHolderBtn?.setTitle(lockStr, for: .normal)
        }
        else {
            self.isUserInteractionEnabled = true
            self.placeHolderBtn?.isHidden = true
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let t = textField.text
        if t?.isEmpty == true {
            return false
        }
        var atUsers = self.atCache.allAtPubkey(ofSenderText: t!)
        var isAtAll = false
        if let index = atUsers?.firstIndex(of: FakeAtALLPubkey) {
            isAtAll = true
            atUsers?.remove(at: index)
        }
        
        let sender = (textField.text, isAtAll, atUsers)
        publish.onNext(sender)
        
        if clearTextAfterSend {
            textField.text = ""
        }
        clear()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" && range.length == 1 {
            
            return  onTextDelete()
        }
        
        
        checkAt(text: string)
        
        
        let str = self.textField.text?.appending(string)
        let count = str?.count ?? 0
        if count  > maxTextLength {
            return false
        }
        
        return true
    }
    
    
    fileprivate func clear() {
        self.atCache.clean()
    }
    
    fileprivate func checkAt(text: String) {
        guard text == InputAtStartChar else {
            return
        }
        guard self.roomService?.chatContact?.value.sessionType == SessionType.group else {
            return
        }
        toAtSelectPage()
    }
    
    fileprivate func toAtSelectPage() {
        if let vc = R.loadSB(name: "ContactAtSelectVC", iden: "ContactAtSelectVC") as? ContactAtSelectVC {
            vc.atSelectBack = { [weak self] (contacts, isAtAll) in
                self?.setContainerVC(autoDismiss: true)
                if isAtAll {
                    let text = "@all".localized().appending(InputAtEndChar)
                    self?.insertText(text: text)
                    
                    let item = InputAtItem()
                    item.name = "@all".localized()
                    item.hexPubkey = FakeAtALLPubkey
                    self?.atCache.add(atItem: item)
                }
                else if contacts.isEmpty == false {
                    var str = ""
                    for contact in contacts {
                        str = str.appending(contact.remark)
                        str = str.appending(InputAtEndChar)
                        if contact != contacts.last {
                            str = str.appending(InputAtStartChar)
                        }
                        
                        let item = InputAtItem()
                        item.name = contact.remark
                        item.hexPubkey = contact.publicKey
                        self?.atCache.add(atItem: item)
                    }
                    self?.insertText(text: str)
                }
                
            }
            setContainerVC(autoDismiss: false)
            Router.pushViewController(vc: vc)
        }
    }
    
    fileprivate func setContainerVC(autoDismiss: Bool) {
        if var containerVC = self.viewController as? KeyboardReturn {
            containerVC.autoDismiss = autoDismiss
        }
    }
    
    
    fileprivate func onTextDelete() -> Bool {
        let range = delRangeForAt()
        if range.length == 1 {
            
            return true
        }
        
        self.deleteText(range: range)
        return false
    }
    
    fileprivate func delRangeForAt() -> NSRange {
        let text = self.textField.text as? NSString
        let csRange = self.textField.textSelectedRange ?? NSRange(location: NSNotFound, length: 0)
        
        var range =  self.innerHelper.range(forPrefix: InputAtStartChar, suffix: InputAtEndChar, currentSelect: csRange)
        let selectedRange = csRange
        
        var item: InputAtItem? = nil
        if range.length > 1 {
            let name =  text?.substring(with: range)
            let set =  InputAtStartChar.appending(InputAtEndChar)
            let charset = CharacterSet(charactersIn: set)
            let tmpName = name?.trimmingCharacters(in: charset) ?? ""
            item =  self.atCache.findItem(byName: tmpName)
            if item == nil {
                range = NSRange(location: selectedRange.location - 1, length: 1)
            }
        }
        return range
    }
    
    
   
    
    
    func insertText(text: String) {
        let textStr = text as NSString
        if let range = self.textField.textSelectedRange  {
            let originText = self.textField.text as? NSString
            let replaceText = originText?.replacingCharacters(in: range, with: text)
            let rangeNew = NSRange(location: range.location + textStr.length, length: 0)
            
            self.textField.text = replaceText
            self.status = .text 
            self.textField.textSelectedRange = rangeNew
        }
    }
    
    func deleteText(range: NSRange) {
        let text = self.textField.text as? NSString
        if range.location + range.length <= (text?.length ?? 0)
            && range.location != NSNotFound
            && range.length != 0 {
            
            let replaceText = text?.replacingCharacters(in: range, with: "")
            let rangeNew = NSRange(location: range.location, length: 0)
            
            self.textField.text = replaceText
            self.textField.textSelectedRange = rangeNew
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
            let size = data?.count ?? 0
            if  size > 10 * 1024 * 1024 {
                Toast.show(msg: "Oversized".localized())
                return
            }
            
            DispatchQueue.main.async {
                let dic = ["image":data]
                self.publish.onNext(dic)
            }
            
        }
    }
    
    
    func onSelectedGifData(data: Data?) {
        let size = data?.count ?? 0
        if size > 10 * 1024 * 1024 {
            Toast.show(msg: "Oversized".localized())
            return
        }
        
        DispatchQueue.main.async {
            let dic = ["image":data]
            self.publish.onNext(dic)
        }
    }
}
