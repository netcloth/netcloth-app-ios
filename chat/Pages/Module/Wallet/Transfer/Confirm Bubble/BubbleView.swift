







import UIKit

class TransferRequest: NSObject {
    var token: TokenInterface
    
    var fromAddr: String
    var toAddr: String
    var transferAmount: String 
    var txFee: String 
    
    init(fromAddr: String,
         toAddr: String,
         transferAmount: String,
         txFee: String,
         token: TokenInterface
         ) {
        self.fromAddr = fromAddr
        self.toAddr = toAddr
        self.txFee = txFee
        self.transferAmount = transferAmount
        self.token = token
        
        super.init()
    }
}

class BubbleView: UIView, KeyboardManagerDelegate {
    
    class ConfirmObserver {
        var confirmPwdOK: (() -> Void)?
        var sendResultBack: (() -> Void)?
    }
    
    lazy var confirmObserver = ConfirmObserver()
    
    var transferRequest: TransferRequest?
    
    @IBOutlet weak var contentV: UIView?
    @IBOutlet weak var navContentV: UIView?
    
    @IBOutlet weak var titleL: UILabel?
    @IBOutlet weak var closeBtn: UIButton?
    
    @IBOutlet weak var contentVBottom: NSLayoutConstraint?
    
    @IBAction func onClose() {
        self.removeFromSuperview()
        tmpVC = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentV?.setCorner(size: 20, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        KeyboardManager.shared.setObserver(self)
    }
    
    var tmpVC: BubbleNavVC?
    
    
    static func defaultTransferBubble(_ transferReq: TransferRequest) -> BubbleView {
        
        guard let bv = R.loadNib(name: "BubbleView") as? BubbleView else {
            fatalError("xib error")
        }
        bv.backgroundColor = UIColor(rgb: 0x041036, alpha: 0.6)
        bv.transferRequest = transferReq
        
        let root = R.loadSB(name: "TokenTransferConfirmVC", iden: "TokenTransferConfirmVC") as! TokenTransferConfirmVC
        
        let vc = BubbleNavVC(rootViewController: root)
        bv.tmpVC = vc
        
        bv.navContentV?.addSubview(vc.view)
        
        vc.view.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalToSuperview()
        }
        
        bv.contentV?.showPopTopAnimate()
        
        return bv
    }
    
    func onSendedTransferReq() {
        
        if let vc = R.loadSB(name: "TCSendResultVC", iden: "TCSendResultVC") as? TCSendResultVC {
            tmpVC?.pushViewController(vc, animated: true)
        }
    }
    
    
    func onKeyboardFrame(_ toframe: CGRect, dura: Double, aniCurve: Int) {
        print(toframe)
        if toframe.origin.y >= YYScreenSize().height {
            onKbHidden(dura: dura, aniCurve: aniCurve)
        }
        else {
            onKbTop(Y: toframe.origin.y, kbH: toframe.size.height, dura: dura, aniCurve: aniCurve)
        }
    }
    
    func onKbHidden(dura: Double, aniCurve: Int) {
        self.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: dura, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(aniCurve)), animations: {
            [weak self] in
            self?.contentVBottom?.constant = 0
            self?.layoutIfNeeded()
            }, completion: nil)
    }
    
    func onKbTop(Y:CGFloat, kbH:CGFloat, dura: Double, aniCurve: Int) {
        guard kbH > 0 else {
            return
        }
        
        self.layoutIfNeeded()
        UIView.animateKeyframes(withDuration: dura, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: UInt(aniCurve)), animations: {
            [weak self] in
            self?.contentVBottom?.constant =  100
            self?.layoutIfNeeded()
            }, completion: nil)
    }
    
}

extension BaseViewController {
    
    var bubbleView: BubbleView? {
        var rsp = self.parent?.next
        while rsp != nil {
            if let r = rsp as? BubbleView {
                return r
            }
            rsp = rsp?.next
        }
        return nil
    }
}
