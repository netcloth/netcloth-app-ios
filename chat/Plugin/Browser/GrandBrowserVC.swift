  
  
  
  
  
  
  

import UIKit
import WebKit

class GrandBrowserVC: BaseViewController,WKUIDelegate, WKNavigationDelegate {
    
    fileprivate var webView: WKWebView?
    fileprivate var originUrl: String?
    fileprivate var bridgeHandle: BrowserJsBridgeHandle?
    
    deinit {
        if let apis = self.bridgeHandle?.supportApisName() {
            let webUC = self.webView?.configuration.userContentController
            for name in apis {
                webUC?.removeScriptMessageHandler(forName: name)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWKWebView()
        _load()
    }
    
    fileprivate func setupWKWebView() {
        let config = WKWebViewConfiguration()
        let usercontent = WKUserContentController()
        
        let bridge = BrowserJsBridgeHandle()
        self.bridgeHandle = bridge
        let apis = bridge.supportApisName()
        for name in apis {
            usercontent.add(bridge, name: name)
        }

        config.userContentController = usercontent
        
        let webview = WKWebView(frame: CGRect.zero, configuration: config)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        
        self.view.addSubview(webview)
        webview.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self.view)
        }
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
    
      
    func goBack() {
        self.webView?.goBack()
    }
    
    func goForward() {
        self.webView?.goForward()
    }
    
    func reload() {
        self.webView?.reload()
    }
    
      
    
      
    func webViewDidClose(_ webView: WKWebView) {
        DispatchQueue.main.async {
            Router.dismissVC()
        }
    }
    
      
      
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
      
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
}

