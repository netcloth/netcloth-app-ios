//
//  MiniAppBrowser.swift
//  chat
//
//  Created by Grand on 2020/3/15.
//  Copyright © 2020 netcloth. All rights reserved.
//

import UIKit
import WebKit

class MiniAppBrowserVC: GrandBrowserVC {
    
    var disableCheckUrlJump: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadUrl(string: String) {
        super.loadUrl(string: string)
    }
        
    //MARK:- Override
    override func configUI() {
        super.configUI()
        self.navigationItem.leftBarButtonItem = self.backItem
        self.navigationItem.rightBarButtonItem = self.closeItem
    }
    
    override func supportConfigs() -> (WKWebViewConfiguration, BrowserJsBridgeHandle) {
        if NCUserCenter.shared?.proxy.value.openProxy == true {
            return (WKWebViewConfiguration.proxyConifg(), ProxyBridgeHandle())
        }
        else {
            return (WKWebViewConfiguration(), ProxyBridgeHandle())
        }
    }
    
    override func supportWeb(byConfig: WKWebViewConfiguration) -> WKWebView {
        return WKWebView(frame: CGRect.zero, configuration: byConfig)
    }
    
    override func supportToOtherPage(url: String) {
        toOtherPage(url: url)
    }
    
    override func configEvent() {
        super.configEvent()
        NCUserCenter.shared?.proxy.observable.subscribe(onNext: { [weak self] in
            self?.reloadProxy()
        }).disposed(by: disbag)
    }
    
    func reloadProxy() {
        if NCUserCenter.shared?.proxy.value.openProxy == true {
            self.webView?.configuration.resumeProxy()
        }
        else {
            self.webView?.configuration.revertProxy()
        }
    }
    
    
    
    //MARK:-
//  Discard: js css image  other asset url
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if disableCheckUrlJump {
            decisionHandler(.allow)
            return
        }
        let toUrl = navigationAction.request.url
        let urlstr = toUrl?.absoluteString.lowercased()
        
        if urlstr?.hasPrefix("http") == false {
            decisionHandler(.allow)
            return
        }
        
        if compare(a: urlstr ?? "", b: originUrl ?? "") == true {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
            if let url = toUrl?.absoluteString {
                toOtherPage(url: url)
            }
        }
    }
    
    fileprivate func toOtherPage(url: String) {
        let browser = MiniAppBrowserVC()
        browser.disableCheckUrlJump = true
        browser.loadUrl(string: url)
        Router.pushViewController(vc: browser)
        print("toOther page " + url)
    }
    
    fileprivate func compare(a: String, b:String) -> Bool {
        
        if a == b {
            return true
        }
        var sa = a.replacingOccurrences(of: "/", with: "")
        sa = sa.replacingOccurrences(of: "#", with: "")
        var sb = b.replacingOccurrences(of: "/", with: "")
        sb = sb.replacingOccurrences(of: "#", with: "")
        
        if sa == sb {
            return true
        }
   
        return false
    }
}
