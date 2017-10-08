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

    typealias SuccessHandler = (_ accesToken: String) -> Void
    typealias FailureHandler = (_ error: InstagramError) -> Void

    // MARK: - Properties

    private var client: InstagramClient
    private var success: SuccessHandler?
    private var failure: FailureHandler?

    private var progressView: UIProgressView!
    private var webViewObservation: NSKeyValueObservation!

    // MARK: - Initializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(client: InstagramClient, success: SuccessHandler? = nil, failure: FailureHandler? = nil) {
        self.client = client
        self.success = success
        self.failure = failure

        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        // Initializes progress view
        setupProgressView()

        // Initializes web view
        let webView = setupWebView()

        // Starts authorization
        loadAuthorizationURL(webView: webView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        progressView.removeFromSuperview()
        webViewObservation.invalidate()
    }

    // MARK: -

    private func setupProgressView() {
        let navBar = navigationController!.navigationBar

        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progress = 0.0
        progressView.tintColor = UIColor(red: 0.88, green: 0.19, blue: 0.42, alpha: 1.0)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        navBar.addSubview(progressView)

        let bottomConstraint = NSLayoutConstraint(item: navBar, attribute: .bottom, relatedBy: .equal,
                                                  toItem: progressView, attribute: .bottom, multiplier: 1, constant: 1)
        let leftConstraint = NSLayoutConstraint(item: navBar, attribute: .leading, relatedBy: .equal,
                                                toItem: progressView, attribute: .leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: navBar, attribute: .trailing, relatedBy: .equal,
                                                 toItem: progressView, attribute: .trailing, multiplier: 1, constant: 0)

        navigationController!.view.addConstraints([bottomConstraint, leftConstraint, rightConstraint])
    }

    private func setupWebView() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: view.frame, configuration: webConfiguration)
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

        view.addSubview(webView)

        return webView
    }

    // MARK: -

    func loadAuthorizationURL(webView: WKWebView) {
        let authorizationURL = URL(string: "https://api.instagram.com/oauth/authorize/")

        var components = URLComponents(url: authorizationURL!, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: client.clientId),
            URLQueryItem(name: "redirect_uri", value: client.redirectURI),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: client.scopes.map({ "\($0.rawValue)" }).joined(separator: "+"))
        ]

        let request = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        webView.load(request)
    }

}

// MARK: - WKNavigationDelegate

extension InstagramLoginViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = webView.title
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url!.absoluteString

        if let range = urlString.range(of: "#access_token=") {
            let location = range.upperBound
            let accessToken = urlString[location...]
            decisionHandler(.cancel)
            DispatchQueue.main.async {
                self.success?(String(accessToken))
            }
            return
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 400:
                decisionHandler(.cancel)
                DispatchQueue.main.async {
                    self.failure?(InstagramError(kind: .invalidRequest, message: "Invalid request"))
                }
                return
            default:
                break
            }
        }

        decisionHandler(.allow)
    }

}
