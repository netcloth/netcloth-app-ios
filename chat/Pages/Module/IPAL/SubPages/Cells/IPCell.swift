  
  
  
  
  
  
  

import UIKit

class IPCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView?
    @IBOutlet weak var idL: UILabel?
    @IBOutlet weak var nameL: UILabel?
    @IBOutlet weak var delayTimeL: UILabel?
    @IBOutlet weak var evaluationL: UILabel?
    @IBOutlet weak var connectBtn: UIButton?
    
    var disposeBag = DisposeBag()
    override func prepareForReuse() {
          super.prepareForReuse()
          disposeBag = DisposeBag()
      }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.container?.fakesetLayerCornerRadiusAndShadow(4,
                                                      color: UIColor(rgb: 0x202D47),
                                                      offset: CGSize(width: 0, height: 2),
                                                      radius: 8,
                                                      opacity: 0.04)
    }
    
    
    override func reloadData(data: Any) {
        guard let node = data as? IPALNode else {
            return
        }
        nameL?.text = node.moniker
        if node.ping > 0 && node.ping < NSNotFound {
            delayTimeL?.text = "\("Latency".localized()): \(node.ping)ms"
        } else {
            delayTimeL?.text = nil
        }
        
        let (des, color) = node.pingEvaDes
        evaluationL?.text = des
        evaluationL?.textColor = color
        
        if node.operator_address == IPALManager.shared.store.currentCIpal?.operator_address {
            self.disableConnectBtn()
            self.connectBtn?.setTitle("Connected".localized(), for: .normal)
        }
        else if node.ping == NSNotFound {
            self.disableConnectBtn()
            self.connectBtn?.setTitle("Connect".localized(), for: .normal)
        }
        else {
            self.enableConnectBtn()
            self.connectBtn?.setTitle("Connect".localized(), for: .normal)
        }
    }
    
    func reloadData(atIndex: Int, data: Any) {
        self.idL?.text = "\(atIndex)."
        self.reloadData(data: data)
    }
    
    func disableConnectBtn() {
        self.connectBtn?.isUserInteractionEnabled = false
        self.connectBtn?.backgroundColor = UIColor(hexString: "#F5F7FA")
        self.connectBtn?.layer.borderColor = UIColor(hexString: "#EDEFF2")?.cgColor
        self.connectBtn?.setTitleColor(UIColor(hexString: "#909399"), for: .normal)
    }
    
    func enableConnectBtn() {
        self.connectBtn?.isUserInteractionEnabled = true
        self.connectBtn?.backgroundColor = UIColor.white
        self.connectBtn?.layer.borderColor = UIColor(hexString: "#3D7EFF")?.cgColor
        self.connectBtn?.setTitleColor(UIColor(hexString: "#3D7EFF"), for: .normal)
    }
}

extension IPALNode {
    var pingEvaDes: (String, UIColor) {
        get {
            let p = self.ping
            if p == 0 {
                return ("testing…".localized(), UIColor(hexString: "#3D7EFF")! )
            }
            else if p > 0 && p <= 200 {
                return ("low".localized(), UIColor(hexString: "#169A41")! )
            }
            else if p > 200 && p <= 500 {
                return ("medium".localized(), UIColor(hexString: "#F5A623")! )
            }
            else if p > 500 && p < NSNotFound {
                return ("high".localized(), UIColor(hexString: "#ED6765")! )
            }
            else {
                return ("unable to connect".localized(), UIColor(hexString: "#FF4141")! )
            }
        }
    }
}
