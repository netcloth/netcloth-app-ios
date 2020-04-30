







import UIKit
import WebKit

class GrandBrowserVC: BaseViewController,WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView?
    var bridgeHandle: BrowserJsBridgeHandle?
    var originUrl: String?
    
    let disbag = DisposeBag()
    
    deinit {
        if let apis = self.bridgeHandle?.supportApisName() {
            let webUC = self.webView?.configuration.userContentController
            for name in apis {
                webUC?.removeScriptMessageHandler(forName: name)
            }
        }
        self.webView?.removeObserverBlocks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: Color.app_bg_color)
        setupWKWebView()
        configUI()
        configEvent()
        _load()
    }
    
    var _willAppear: Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if _willAppear == false {
            webView?.isHidden = true
        }
        _willAppear = true
    }
    
    var _didAppear: Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if _didAppear == false {
            webView?.isHidden = false
        }
        _didAppear = true   
    }
    
    
    func supportConfigs() -> (WKWebViewConfiguration, BrowserJsBridgeHandle) {
        return (WKWebViewConfiguration(), BrowserJsBridgeHandle())
    }
    
    func supportWeb(byConfig: WKWebViewConfiguration) -> WKWebView {
        return WKWebView(frame: CGRect.zero, configuration: byConfig)
    }
    
    func supportToOtherPage(url: String) {
        let browser = GrandBrowserVC()
        browser.loadUrl(string: url)
        Router.pushViewController(vc: browser)
    }
    
    
    fileprivate func setupWKWebView() {
        let support = supportConfigs()
        let config = support.0
        let bridge = support.1
        
        let usercontent = WKUserContentController()
        let apis = bridge.supportApisName()
        for name in apis {
            usercontent.add(bridge, name: name)
        }

        config.userContentController = usercontent
        
        let webview = supportWeb(byConfig: config)
        self.view.addSubview(webview)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.scrollView.adjustOffset()
        
        webview.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalTo(self.view)
            if #available(iOS 11.0, *) {
                maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                
                maker.top.equalTo(self.view)
            }
        }
        
        
        self.bridgeHandle = bridge
        self.webView = webview
        bridge.webView = webview
    }
        
    func loadUrl(string: String) {
        originUrl = string
        _load()
    }
    
    fileprivate func _load() {
        guard let web = webView,
            let url = originUrl,
            let URL = URL(string: url) else {
                return
        }
        let request = URLRequest(url: URL)
        web.load(request)
    }
    
    
    func configUI() {
        self.view.addSubview(progressView)
        progressView.isHidden = true
        progressView.snp.makeConstraints { (maker) in
            maker.left.equalTo(self.view)
            maker.height.equalTo(0.5)
            if #available(iOS 11.0, *) {
                maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                
                maker.top.equalTo(self.view)
            }
            maker.width.equalTo(0)
        }
    }
    
    func configEvent() {
        self.webView?.addObserverBlock(forKeyPath: "title", block: { [weak self] (obj, oldv, newv) in
            if self?.title == nil,
                let nv = newv as? String {
                self?.title = nv
            }
        })
        
        self.webView?.addObserverBlock(forKeyPath: "estimatedProgress", block: { [weak self] (obj, oldv, newv) in
            if let nv = newv as? Double {
                self?.setProgressAnimate(p: CGFloat(nv))
            }
        })
    }
    

    lazy var progressView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexString: Color.blue)
        return v
    }()
    
    func setProgressAnimate(p: CGFloat) {
        var len = self.view.size.width * p
        len = max(0,len)
        progressView.snp.updateConstraints { (maker) in
            maker.width.equalTo(len)
        }
        self.progressView.setNeedsLayout()
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.layoutIfNeeded()
        })
    }
    
    lazy var backItem: UIBarButtonItem = {
        let image = UIImage(named: "返回1")
        let v = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(onBackAction))
        return v
    }()
    
    @objc func onBackAction() {
        if checkCanBack() {
            self.webView?.goBack()
        }
        else {
            Router.dismissVC()
        }
    }
    
    lazy var closeItem: UIBarButtonItem = {
        let image = UIImage(named: "btn_web_close")
        let v = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.plain, target: self, action: #selector(onCloseAction))
        return v
    }()
    
    @objc func onCloseAction() {
        Router.dismissVC(animate: true, completion: nil, toRoot: true)
    }
    
    func checkCanBack() -> Bool {
        return self.webView?.canGoBack == true
    }
    
    
    func goBack() {
        self.webView?.goBack()
    }
    
    func goForward() {
        self.webView?.goForward()
    }
    
    func reload() {
        self.webView?.reload()
    }
    
    
    func webViewDidStart() {
        progressView.isHidden = false
    }
    func webViewLoadFinish() {
        progressView.isHidden = true
    }
    
    
    func webViewDidClose(_ webView: WKWebView) {
        DispatchQueue.main.async {
            Router.dismissVC()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let url = navigationAction.request.url?.absoluteString {
            supportToOtherPage(url: url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController =  UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Confirm".localized(), style: UIAlertAction.Style.default) { (action) in
            completionHandler()
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController =  UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        
        var action = UIAlertAction(title: "Cancel".localized(), style: UIAlertAction.Style.cancel) { (action) in
            completionHandler(false)
        }
        alertController.addAction(action)
        
        action = UIAlertAction(title: "Confirm".localized(), style: UIAlertAction.Style.default) { (action) in
            completionHandler(true)
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewDidStart()
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewLoadFinish()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webViewLoadFinish()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
       webViewLoadFinish()
    }
}

