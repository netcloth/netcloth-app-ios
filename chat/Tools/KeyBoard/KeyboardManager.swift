







import Foundation


@objc protocol KeyboardManagerDelegate {
    @objc optional func onKeyboardFrame(_ toframe:CGRect, dura: Double, aniCurve:Int) -> Void
}


class KeyboardManager: NSObject {
    static let shared = KeyboardManager()
    

    func setObserver(_ obv: KeyboardManagerDelegate ) {
        self.delegate = obv
    }
    

    private weak var delegate: KeyboardManagerDelegate?
    override init() {
        super.init()
        registerNotice()
    }
    
    func registerNotice() {
        let didChange = UIResponder.keyboardWillChangeFrameNotification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameDidChange(notice:)), name: didChange, object: nil)
    }
    
    func unRegisterNotice() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardFrameDidChange(notice:NSNotification) {
        guard let userinfo = notice.userInfo else {
            return
        }
        



        
        guard let frame =  userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        guard let dura = userinfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        guard let animateCurve = userinfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else {
            return
        }
        
        self.delegate?.onKeyboardFrame?(frame.cgRectValue, dura: dura.doubleValue,aniCurve: animateCurve.intValue)
    }

}
