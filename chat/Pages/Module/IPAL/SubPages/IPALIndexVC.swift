







import UIKit

class IPALIndexVC: BaseViewController {
    
    @IBOutlet weak var cipalContainer: UIView?
    @IBOutlet weak var cipalLabel: UILabel?
    
    @IBOutlet weak var aipalContainer: UIView?
    @IBOutlet weak var aipalLabel: UILabel?
    
    
    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            self.isShowLargeTitleMode = true
        } else {

        }
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fillData()
    }
    
    
    func configUI() {
                
        cipalContainer?.fakesetLayerCornerRadiusAndShadow( 4,
                                                       color: UIColor(hexString: "#BFC2CC")!,
                                                       offset: CGSize(width: 0, height: 2),
                                                       radius: 7,
                                                       opacity: 0.3)
        aipalContainer?.fakesetLayerCornerRadiusAndShadow( 4,
                                                       color: UIColor(hexString: "#BFC2CC")!,
                                                       offset: CGSize(width: 0, height: 2),
                                                       radius: 7,
                                                       opacity: 0.3)
    }
    
    func fillData() {
        let node = IPALManager.shared.store.currentCIpal
        self.cipalLabel?.text = node?.moniker
        self.aipalLabel?.text = nil
    }
    
    @IBAction func toC_IPAL() {
        if let vc = R.loadSB(name: "IPALList", iden: "IPAListVC") as? IPAListVC {
            Router.pushViewController(vc: vc)
            vc.fromSource = .C_IPAL
        }
    }
    
    @IBAction func toA_IPAL() {
        
    }
    
}
