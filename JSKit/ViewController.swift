//
//  ViewController.swift
//  JSKit
//
//  Created by 谈超 on 2017/8/25.
//  Copyright © 2017年 谈超. All rights reserved.
//

import UIKit
import WebKit
class ViewController: UIViewController {
    lazy private  var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
//        let preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.processPool = WKProcessPool()
        let usrScript = WKUserScript(source: JSBridge.shared.handleJS, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        config.userContentController = WKUserContentController()
        config.userContentController.addUserScript(usrScript)
        
        config.userContentController.add(JSBridge.shared, name: JSBridgeHandle)
        
        return WKWebView(frame: self.view.bounds, configuration: config)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        JSBridge.shared.webView = webView
        let request =  URLRequest(url: URL(string: "file://\(Bundle.main.path(forResource: "test", ofType: "html")!)")!)
        webView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController : WKUIDelegate,WKNavigationDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
}

