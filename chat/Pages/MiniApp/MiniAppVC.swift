







import UIKit
import WebKit

class MiniAppVC: BaseViewController {
    
    weak var appBrowserVC: MiniAppBrowserVC?
    @IBOutlet weak var bindTipL: UILabel?
    let disbag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHideNavBar = true
        configUI()
        configEvent()
        fillUI()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configUI() {
        self.tabBarItem.setStyle(imgName: "小应用-未选中",
                                 selectedName: "小应用-选中",
                                 textColor: UIColor(hexString: Color.gray),
                                 selectedColor: UIColor(hexString: Color.black))
    }
    
    @objc @IBAction func refreshWeb() {
        refreshWebView()
    }
    
    func configEvent() {
        IPALManager.shared.store.rx.observe(IPALNode.self, "curAIPALNode").subscribe {[weak self] (event) in
            self?.fillUI()
        }.disposed(by: disbag)
    }
    
    func fillUI() {
        deleteWKWebCache()
        refreshWebView()
    }
    
    func refreshWebView() {
        IPALManager.shared.store.findCurAIpalNode { (anode) in
            let node = anode
            let nodename = node?.moniker ?? ""
            self.bindTipL?.text = nodename
            let url = node?.aIpal()?.endpoint ?? ""
            self.appBrowserVC?.loadUrl(string: url)
        }
    }
    
    fileprivate func deleteWKWebCache() {
        let array = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
        let set: Set<String> = Set(array)
        
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: set, modifiedSince: date) {
            
        }
    }
    
    @IBAction func onSwitchAIPAL(_ sender: Any) {
        
        if let vc = R.loadSB(name: "IPALList", iden: "IPAListVC") as? IPAListVC {
            Router.pushViewController(vc: vc)
            vc.fromSource = .A_IPAL
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MiniAppBrowserVC {
            self.appBrowserVC = vc
        }
    }
    
}
