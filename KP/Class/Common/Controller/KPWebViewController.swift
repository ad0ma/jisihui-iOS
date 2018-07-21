//
//  KPWebViewController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/27.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import WebKit

class KPWebViewController: KPBaseViewController, WKNavigationDelegate, UIWebViewDelegate {
    
    var urlStr: String? {
        didSet {
            guard let urlS = urlStr,
                let url =  URL.init(string: urlS) else {
                    return
            }
            
            let request = URLRequest.init(url: url)

            theWeb.loadRequest(request)
        }
    }
    
    var theWeb: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theWeb = UIWebView.init(frame: CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH))
        
        theWeb.delegate = self
        
        view.addSubview(theWeb)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(turnBack))
    }
    
    @objc func turnBack() {
        if theWeb.canGoBack {
            theWeb.goBack()
        } else {
            self.kp_navigationController?.popViewController(animated: true)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        KPHud.showWaiting()

        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        KPHud.hideNotice()

    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         KPHud.hideNotice()
    }
    
}
