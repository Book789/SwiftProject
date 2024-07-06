//
//  BaseWebViewController.swift
//  swiftBase
//
//  Created by Book on 2023/3/22.
//

import UIKit
import WebKit

private let kKVOContentSizekey: String = "contentSize"
private let kKVOTitlekey: String = "title"


class BaseWebViewController: UIViewController {

    var webView: WKWebView!
    var URLString: String!
    var titleString: String?
    
    var progressView:UIProgressView = UIProgressView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
//        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = false
//
//        let configuration = WKWebViewConfiguration()
//        configuration.preferences = preferences
        
        self.webView = WKWebView(frame: self.view.bounds)
        self.webView.scrollView.bounces = true
        self.webView.scrollView.isScrollEnabled = true
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)

        let urlRequest = URLRequest(url: URL(string: URLString!)!)
        self.webView.load(urlRequest)
        
        self.webView.addObserver(self, forKeyPath:kKVOContentSizekey, options:.new, context:nil)
        self.webView.addObserver(self, forKeyPath:kKVOTitlekey, options:.new, context:nil)
        self.webView.addObserver(self, forKeyPath:"estimatedProgress", options: .new, context:nil)

        
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints { (make)in
         make.width.equalToSuperview()
         make.height.equalTo(3)
         make.top.equalToSuperview()
        }
        progressView.tintColor = UIColor.red
        progressView.isHidden = true

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case kKVOContentSizekey?:
            if let height = change![NSKeyValueChangeKey.newKey] as? Float {
                self.webView?.scrollView.contentSize.height = CGFloat(height)
            }
            break
        case kKVOTitlekey?:
            if self.titleString != nil {
                return
            }
            if let title = change![NSKeyValueChangeKey.newKey] as? String {
                self.title = title
            }
            break
        case "estimatedProgress"?:

            let newprogress = change?[.newKey] as? Double ?? 0.0
            let oldprogress = change?[.kindKey] as? Double ?? 0.0

             //不要让进度条倒着走...有时候goback会出现这种情况
//             if (newprogress < oldprogress) {
//
//                 return
//             }

             if newprogress == 1 {
              progressView.isHidden  = true
              progressView.setProgress(0, animated:false)
             }
            else {
                progressView.isHidden = false
                progressView.setProgress(Float(newprogress), animated:true)
            }
        break


        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        self.webView?.removeObserver(self, forKeyPath:kKVOContentSizekey)
        self.webView?.removeObserver(self, forKeyPath:kKVOTitlekey)
        self.webView?.removeObserver(self, forKeyPath:"estimatedProgress")
    }

}
// MARK: - @delegate WKNavigationDelegate
extension BaseWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)){
        decisionHandler(.allow)
    }
}
