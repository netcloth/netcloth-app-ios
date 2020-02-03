  
  
  
  
  
  
  

import UIKit

class AlertView: UIView {
    
    var cancelBlock: (() -> Void)?
    var okBlock: (() -> Void)?   
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var msgLabel: UILabel?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var okButton: UIButton?   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
    }
    
    @IBAction func onOkTap() {
        Router.dismissVC { [weak self] in
            self?.okBlock?()
        }
    }
    
    @IBAction func onCancelTap() {
        Router.dismissVC { [weak self] in
            self?.cancelBlock?()
        }
    }
}

  
class NormalAlertView: AlertView, NCAlertInterface {
    
}

  
class OneButtonAlert: AlertView, NCAlertInterface {
}

class OneButtonOneMsgAlert: AlertView, NCAlertInterface {
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 150)
    }
}


  
class NormalInputAlert: AlertView, NCAlertInterface {
    @IBOutlet weak var inputTextField: UITextField?
    
    var checkPreview: (() -> Bool)?
    
    override func onOkTap() {
        if let check = self.checkPreview {
            if check() {
                super.onOkTap()
            }
        } else {
            super.onOkTap()
        }
    }
}

  
class ErrorTipsInputAlert: NormalInputAlert {
    @IBOutlet weak var checkTipsLabel: UILabel?
    
    var disbag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configEvent()
    }
    
      
    func configEvent() {
        inputTextField?.rx.text.subscribe { [weak self] (event: Event<String?>) in
            if let e = event.element, e?.isEmpty == false {
            } else {
                self?.checkTipsLabel?.isHidden = true
            }
        }.disposed(by: disbag)
    }
}


class RetrySendAlert: AlertView, NCAlertInterface {
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}

  
class MayEmptyAlertView: AlertView, NCAlertInterface {
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 152)
    }
}
