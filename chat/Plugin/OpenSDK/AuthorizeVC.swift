  
  
  
  
  
  
  

import UIKit

class AuthorizeVC: UIViewController {
    
    var cancelAction: (() -> Void)?
    var agreeAction: (() -> Void)?
    var requestData: NSDictionary?
    
    @IBOutlet weak var bottomV: UIView?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var accountAddressL: UILabel!
    @IBOutlet weak var accountNameL: UILabel!
    @IBOutlet weak var tipsL: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    var _viewWillAppear = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if _viewWillAppear == false {
            _viewWillAppear = true
            animateShow()
        }
    }
    
    
    func show() {
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        Router.present(vc: self)
    }
    
    /*
     var o = new Object()
     o.icon = icon
     o.name = name
     o.publicKey = publicKey
     o.timestamp = timestamp
     o.signature = signature
     */
    func configUI() {
        
        if let data = requestData {
            let icon = (data["icon"] as? String) ?? ""
            let name = (data["name"] as? String) ?? ""
            
            self.iconImgV.nw_setImage(urlString: icon)
            
            var tip = "Auth_name_tip".localized()
            tip = tip.replacingOccurrences(of: "#mark#", with: name)
            self.nameL.text = tip  
        }
        
        self.view?.setNeedsLayout()
        self.view?.layoutIfNeeded()
        let height = self.bottomV?.height ?? 0
        self.bottomConstraint.constant = height
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        
        animateDismiss {
            Router.dismissVC(animate: false) { [weak self] in
                self?.cancelAction?()
            }
        }
    }
    
    @IBAction func agree(_ sender: Any) {
        
        animateDismiss {
            Router.dismissVC(animate: false) { [weak self] in
                self?.agreeAction?()
            }
        }
    }
    
      
    fileprivate func animateShow() {
        self.view?.layoutIfNeeded()
        UIView.animate(withDuration: 0.25, animations: {
            self.view?.layoutIfNeeded()
            self.bottomConstraint.constant = 0
        }, completion: nil)
    }
    
    fileprivate func animateDismiss(completion:(() -> Void)? = nil) {
        self.view?.setNeedsLayout()
        self.view?.layoutIfNeeded()
        let height = self.bottomV?.height ?? 0
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomConstraint.constant = height
            self.view.layoutIfNeeded()
        }, completion: { r in
            completion?()
        })
    }
    
    
}
