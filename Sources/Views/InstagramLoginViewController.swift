//
//  InstagramLoginViewController.swift
//  SwiftInstagram
//
//  Created by Ander Goig on 8/9/17.
//  Copyright © 2017 Ander Goig. All rights reserved.
//

import UIKit
import WebKit

class InstagramLoginViewController: UIViewController {

    // MARK: - Types

    public typealias SuccessHandler = (_ accesToken: String) -> Void
    public typealias FailureHandler = (_ error: Error) -> Void

    // MARK: - Properties

    private var api = Instagram.shared

    private var clientId: String
    private var authScopes: [InstagramAuthScope]
    private var redirectURI: String
    private var success: SuccessHandler?
    private var failure: FailureHandler?

    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var webViewObservation: NSKeyValueObservation!

    // MARK: - Customizable Properties

    public var customTitle: String?
    public var progressViewTintColor = UIColor(red: 0.88, green: 0.19, blue: 0.42, alpha: 1.0)

    // MARK: - Initializers

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(clientId: String, authScopes: [InstagramAuthScope], redirectURI: String, success: SuccessHandler? = nil, failure: FailureHandler? = nil) {
        self.clientId = clientId
        self.authScopes = authScopes
        self.redirectURI = redirectURI
        self.success = success
        self.failure = failure

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - View Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        if self.customTitle != nil {
            self.navigationItem.title = self.customTitle
        }

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }

        let navBar = navigationController!.navigationBar

        // Initializes progress view
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress = 0.0
        progressView.tintColor = self.progressViewTintColor
        progressView.translatesAutoresizingMaskIntoConstraints = false

        navBar.addSubview(progressView)

        let bottomConstraint = NSLayoutConstraint(item: navBar, attribute: .bottom, relatedBy: .equal,
                                                  toItem: progressView, attribute: .bottom, multiplier: 1, constant: 1)
        let leftConstraint = NSLayoutConstraint(item: navBar, attribute: .leading, relatedBy: .equal,
                                                toItem: progressView, attribute: .leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: navBar, attribute: .trailing, relatedBy: .equal,
                                                 toItem: progressView, attribute: .trailing, multiplier: 1, constant: 0)

        navigationController!.view.addConstraints([bottomConstraint, leftConstraint, rightConstraint])

        // Initializes web view
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self

        webViewObservation = webView.observe(\.estimatedProgress) { (view, _ change) in
            self.progressView.alpha = 1.0
            self.progressView.setProgress(Float(view.estimatedProgress), animated: true)
            if view.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
                    self.progressView.alpha = 0.0
                }, completion: { (_ finished) in
                    self.progressView.progress = 0
                })
            }
        }

        self.view.addSubview(webView)

        // Start authorization
        loadAuthorizationURL()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        progressView.removeFromSuperview()
        webViewObservation.invalidate()
    }

    // MARK: -

    private func loadAuthorizationURL() {
        let authorizationURL = URL(string: InstagramURL.oauth + "/oauth/authorize/")
        var components = URLComponents(url: authorizationURL!, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: self.clientId),
            URLQueryItem(name: "redirect_uri", value: self.redirectURI),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: self.authScopes.map({ "\($0.rawValue)" }).joined(separator: "+"))
        ]

        let request = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        webView.load(request)
    }

}

// MARK: - WKNavigationDelegate

extension InstagramLoginViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.customTitle == nil {
            self.navigationItem.title = webView.title
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url!.absoluteString

        if let range = urlString.range(of: "#access_token=") {
            let location = range.upperBound
            let accessToken = urlString[location...]
            DispatchQueue.main.async {
                self.success?(String(accessToken))
            }
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

}
