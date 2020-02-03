  
  
  
  
  
  
  

import UIKit

class GroupManageAlert: AlertView , NCAlertInterface {
    
    @IBOutlet weak var onlyAdminImg: UIImageView?
    @IBOutlet weak var onlyAdminControl: UIControl?
    
    @IBOutlet weak var invApprovalImg: UIImageView?
    @IBOutlet weak var invApprovalControl: UIControl?
    
    @IBOutlet weak var everyCanImg: UIImageView?
    @IBOutlet weak var everyCanControl: UIControl?
    
    let disbag =  DisposeBag()
    
    var onlyAdminHandle: (() -> Void)?
    var invApprovalHandle: (() -> Void)?
    var everyCanHandle: (() -> Void)?
    
    func hightlightRecieve(isOnlyAdmin:Bool,
                           invApproval:Bool,
                           everyCan: Bool) {
        
        onlyAdminImg?.image = isOnlyAdmin ? UIImage(named: "group_select") :  UIImage(named: "group_un_select")
        invApprovalImg?.image = invApproval ? UIImage(named: "group_select") :  UIImage(named: "group_un_select")
        everyCanImg?.image = everyCan ? UIImage(named: "group_select") :  UIImage(named: "group_un_select")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configEvent()
    }
    
    func ncSize() -> CGSize {
        return CGSize(width: 300, height: 283)
    }
    
    func configEvent() {
        self.onlyAdminControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.onlyAdminHandle?()
            self?.onOkTap()
        }).disposed(by: disbag)
        
        self.invApprovalControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.invApprovalHandle?()
            self?.onOkTap()
        }).disposed(by: disbag)
        
        self.everyCanControl?.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            self?.everyCanHandle?()
            self?.onOkTap()
        }).disposed(by: disbag)
    }
}
