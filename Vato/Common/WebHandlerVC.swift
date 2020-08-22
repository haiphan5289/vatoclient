//  File name   : WebHandlerVC.swift
//
//  Author      : Dung Vu
//  Created date: 5/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import UIKit
import SnapKit
import FwiCore
import RxSwift
import RxCocoa
import WebKit
final class WebHandlerVC: UIViewController {
    
    struct Config {
        static let headerH: CGFloat = 44
        static let edge = UIApplication.shared.keyWindow?.edgeSafe ?? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        static let messageError = Text.thereWasAnError.localizedText
    }
    
    typealias WebHandlerBlock = (_ controller: UIViewController?, _ surl: URL?) -> Void
    
    /// Class's public properties.
    private lazy var containerHeader: UIView = {
        return createView {
            $0 >>> view >>> {
                $0.snp.makeConstraints { (make) in
                    make.height.equalTo(Config.headerH + (Config.edge.top > 0 ? Config.edge.top : 20))
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalToSuperview()
                }
            }
        }
    }()
    
    private lazy var containerView: UIView = {
        return createView({ (v) in
            v >>> view >>> {
                $0.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.right.equalToSuperview()
                    make.top.equalTo(self.containerHeader.snp.bottom)
                    make.bottom.equalToSuperview()
                }
            }
        })
    }()
    
    private lazy var progressView: UIProgressView = {
        return createView {
            $0.progressTintColor = Color.orange
            $0.trackTintColor = .clear
            $0.progressViewStyle = .default
            $0.progress = 0
            $0.isHidden = true
            $0 >>> self.containerView >>> {
                $0.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.height.equalTo(3)
                    make.right.equalToSuperview()
                    make.top.equalToSuperview()
                }
            }
        }
    }()
    
    private lazy var webView: WKWebView = {
        return createView {
                $0.navigationDelegate = self
                $0 >>> self.containerView >>> {
                    $0.snp.makeConstraints { (make) in
                        make.edges.equalToSuperview()
                }
            }
        }
    }()
    
    private lazy var lblTitle: UILabel = {
        return createView {
            
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .white
            $0 >>> self.containerHeader >>> {
                $0.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.bottom.equalTo(-14)
                    make.width.lessThanOrEqualTo(250)
                }
            }
        }
    }()
    
    private lazy var btnClose: UIButton = {
        return createView {
            $0.tintColor = .white
            $0 >>> self.containerHeader >>> {
                $0.snp.makeConstraints { (make) in
                    make.centerY.equalTo(lblTitle.snp.centerY)
                    make.left.equalTo(16)
                    make.size.equalTo(CGSize(width: 44, height: 44))
                }
            }
        }
    }()
    
    private lazy var refreshControl = UIRefreshControl(frame: .zero)
    private lazy var noItemView = NoItemView(imageName: self.type.errorCustom.iconError, message: self.type.errorCustom.messageError, on: self.webView.scrollView) { [weak self](v) in
        v.frame = self?.webView.bounds ?? .zero
    }
    
    private var url: URL?
    private var mTitle: String?
    private lazy var disposeBag = DisposeBag()
    private var isBlanked: Bool = false
    private var currentDecision: WKNavigationActionPolicy = .allow
    private var type: WebVCType!
    private var accessToken: String?
    private var handler: WebHandlerBlock?
    private var currentURL: URL?
    
    convenience init(with url: URL?, title: String?, type: WebVCType, accessToken: String? = nil, handler: WebHandlerBlock?) {
        self.init(nibName: nil, bundle: nil)
        self.type = type
        self.url = url
        self.mTitle = title
        self.accessToken = accessToken
        self.handler = handler
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.setStatusBar(using: .lightContent)
        visualize()
        setupRX()
        loadURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defer { clearCache() }
        guard self.webView.isLoading else {
            return
        }
        self.webView.stopLoading()
    }

    /// Class's private properties.
    private func createView<T: UIView>(_ block: (T) -> ()) -> T {
        let v = T.init(frame: .zero)
        block(v)
        return v
    }
    
    deinit {
        printDebug("\(#function)")
    }
}

// MARK: Class's public methods
extension WebHandlerVC {
    static func loadWebCustom(on controller: UIViewController?, url: URL?, title: String?, type: WebVCType, handler: WebHandlerBlock?) {
        guard let controller = controller else {
            return
        }
        
        let webVC = WebHandlerVC(with: url, title: title, type: type, accessToken: nil, handler: handler)
        webVC.modalTransitionStyle = .coverVertical
        webVC.modalPresentationStyle = .fullScreen
        controller.present(webVC, animated: true, completion: nil)
    }
}

// MARK: Class's private methods
private extension WebHandlerVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = .white
        lblTitle.textAlignment = .center
        btnClose.setImage(#imageLiteral(resourceName: "close-g").withRenderingMode(.alwaysTemplate) ,for: .normal)
        btnClose.contentHorizontalAlignment = .left
        self.webView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        self.lblTitle.text = self.mTitle
        self.containerHeader.backgroundColor = Color.orange
        self.webView.scrollView.addSubview(self.refreshControl)
        self.noItemView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
        self.webView.scrollView.backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
    }
    
    private func loadURL() {
        guard let url = self.url else {
            noItemView.attach()
            return
        }
        var request = URLRequest(url: url)
        if let accessToken = self.accessToken {
            request.setValue(accessToken, forHTTPHeaderField: "x-access-token")
        }
        self.webView.load(request)
    }
    
    private func loadBlank() {
        isBlanked = true
        let url: URL = "about:blank"
        webView.load(URLRequest(url: url))
    }
    
    private func clearCache() {
        let dataTypes = Set([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        self.webView.rx.observeWeakly(Bool.self, #keyPath(WKWebView.isLoading)).bind { [weak self] in
            let isLoading = ($0 ?? false)
            self?.progressView.isHidden = !isLoading
            guard !isLoading, self?.refreshControl.isRefreshing == true else {
                return
            }
            self?.refreshControl.endRefreshing()
        }.disposed(by: disposeBag)
        
        self.webView.rx.observeWeakly(Double.self, #keyPath(WKWebView.estimatedProgress)).bind { [weak self] in
            self?.progressView.progress = Float($0 ?? 0)
        }.disposed(by: disposeBag)
        
        btnClose.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        self.refreshControl.rx.controlEvent(.valueChanged).bind { [weak self](_) in
            self?.refreshControl.beginRefreshing()
            self?.loadURL()
        }.disposed(by: disposeBag)
        
        if self.mTitle == nil || self.mTitle?.isEmpty == true {
            self.webView.rx.observeWeakly(String.self, #keyPath(WKWebView.title)).bind { [weak self] in
                self?.lblTitle.text = $0
            }.disposed(by: disposeBag)
        }
    }
}

extension WebHandlerVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        noItemView.attach()
        loadBlank()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard currentDecision == .allow else {
            return
        }
        noItemView.attach()
        loadBlank()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        defer {
            handler?(self, currentURL)
        }
        guard !isBlanked else {
            return
        }
        noItemView.detach()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check
        isBlanked = webView.url?.absoluteString.contains("blank") ?? false
        currentURL = navigationAction.request.url
        decisionHandler(.allow)
    }
}
