  
  
  
  
  
  
  

import UIKit

class GroupNameInputVC: BaseViewController {
    
    @IBOutlet weak var nameInputTF: UITextField?
    @IBOutlet weak var sepV: UIView?
    
    @IBOutlet weak var confirmBtn: UIButton?
    
    let disbag = DisposeBag()

    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {
              
        }
        
        super.viewDidLoad()
        
        configUI()
        configEvent()
    }
    
    func configUI() {
        confirmBtn?.setShadow(color: UIColor(hexString: Config.Color.shadow_Layer)!, offset: CGSize(width: 0,height: 10), radius: 20, opacity: 0.3)
    }
    
    func configEvent() {
        nameInputTF?.rx.text.subscribe(onNext: { [weak self] (text) in
            if text?.isEmpty == true {
                self?.sepV?.backgroundColor = UIColor(hexString: "#E9E9E9")
            } else {
                self?.sepV?.backgroundColor = UIColor(hexString: "#303133")
            }
        }).disposed(by: disbag)
        
        nameInputTF?.rx.text.map({ (text) -> Bool in
            if text?.isEmpty == true {
                return false
            } else {
                return true
            }
        }).bind(to: confirmBtn!.rx.isEnabled).disposed(by: disbag)
        
        nameInputTF?.rx.text.map({ (text) -> CGFloat in
            if text?.isEmpty == true {
                return 0.3
            } else {
                return 1.0
            }
        }).bind(to: confirmBtn!.rx.alpha).disposed(by: disbag)
        
        
        confirmBtn?.rx.tap.subscribe(onNext: { [weak self] in
            self?.toNext()
        }).disposed(by: disbag)
    }
    
      
    func toNext() {
        if let vc = R.loadSB(name: "GroupCreate", iden: "GroupSelectContactVC") as? GroupSelectContactVC {
            vc.groupName = nameInputTF?.text
            Router.pushViewController(vc: vc)
        }
    }

}
