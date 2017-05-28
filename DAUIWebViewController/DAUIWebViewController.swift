//
//  ViewController.swift
//  JSONParserTest
//
//  Created by Dejan on 22/05/2017.
//  Copyright © 2017 Dejan. All rights reserved.
//

import UIKit

class DAUIWebViewController: UIViewController {

    public var elementsToRemove: [String] = [
        "masthead",
        "secondary",
        "sharedaddy sd-sharing-enabled",
        "jp-relatedposts",
        "sharedaddy sd-block sd-like jetpack-likes-widget-wrapper jetpack-likes-widget-loaded",
        "entry-meta",
        "nav-single",
        "comments",
        "colophon"
    ]
    public var internalHosts: [String] = ["agostini.tech"]
    public var favourites: [String] = []
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backButton: UIBarButtonItem?
    @IBOutlet weak var forwardButton: UIBarButtonItem?
    @IBOutlet weak var favouriteButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPost()
    }

    func getPost() {
        loadURL(urlString: "http://agostini.tech/2017/05/22/using-sirikit/")
    }
    
    func loadURL(urlString: String) {
        
        if let url = URL(string: urlString) {
            self.webView.loadRequest(URLRequest(url: url))
        }
    }
    
    fileprivate func setFavouriteButton() {
        guard let url = self.webView.request?.url?.absoluteString else {
            return
        }
        
        if self.favourites.contains(url) {
            self.favouriteButton?.tintColor = .red
        } else {
            self.favouriteButton?.tintColor = .green
        }
    }
    
    fileprivate func addFavourite(fav: String) {
        if self.favourites.contains(fav) == false {
            self.favourites.append(fav)
        }
    }
    
    fileprivate func removeFavourite(fav: String) {
        if let index = self.favourites.index(of: fav) {
            self.favourites.remove(at: index)
        }
    }
}

// MARK: Button actions
extension DAUIWebViewController {
    @IBAction func goBack() {
        self.webView.goBack()
    }
    
    @IBAction func goForward() {
        self.webView.goForward()
    }
    
    @IBAction func reload() {
        self.webView.reload()
    }
    
    @IBAction func favourite(button: UIBarButtonItem) {
        guard let url = self.webView.request?.url?.absoluteString else {
            return
        }
        
        if self.favourites.contains(url) {
            self.removeFavourite(fav: url)
        } else {
            self.addFavourite(fav: url)
        }
        
        self.setFavouriteButton()
    }
    
    @IBAction func openInSafari() {
        if let url = self.webView.request?.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: UIWebViewDelegate
extension DAUIWebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.url, navigationType == .linkClicked, isExternalHost(forURL: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            return false
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.startActivityIndicator()
        self.removeElements(fromWebView: webView)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.removeElements(fromWebView: webView)
        self.backButton?.isEnabled = webView.canGoBack
        self.forwardButton?.isEnabled = webView.canGoForward
        self.stopActivityIndicator()
        self.setFavouriteButton()
    }
    
    private func startActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    private func stopActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func isExternalHost(forURL url: URL) -> Bool {
        
        if let host = url.host, internalHosts.contains(host) {
            return false
        }
        
        return true
    }
    
    private func removeElements(fromWebView webView: UIWebView) {
        self.elementsToRemove.forEach { self.removeElement(elementID: $0, fromWebView: webView) }
    }
    
    private func removeElement(elementID: String, fromWebView webView: UIWebView) {
        let removeElementIdScript = "var element = document.getElementById('\(elementID)'); element.parentElement.removeChild(element);"
        webView.stringByEvaluatingJavaScript(from: removeElementIdScript)
        
        let removeElementClassScript = "document.getElementsByClassName('\(elementID)')[0].style.display=\"none\";"
        webView.stringByEvaluatingJavaScript(from: removeElementClassScript)
    }
}

