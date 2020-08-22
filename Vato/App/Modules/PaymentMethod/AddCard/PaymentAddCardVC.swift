//  File name   : PaymentAddCardVC.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift
import UIKit
import SnapKit

import WebKit
import FwiCoreRX

protocol PaymentAddCardPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    var mURL: URL { get }
    func paymentAddCardMoveBack()
    func paymentAddCardSuccess()
}

final class PaymentAddCardVC: UIViewController, PaymentAddCardPresentable, PaymentAddCardViewControllable, LoadingAnimateProtocol, DisposableProtocol {

    struct Config {
        struct Debug {
            static let prefix = "D PaymentAddCardVC :"
        }
        
        static let title = Text.addCard.localizedText
        
        struct Error {
            static let icon = "notify_noItem"
            static let message = Text.thereWasAnError.localizedText
        }
    }
    /// Class's public properties.
    weak var listener: PaymentAddCardPresentableListener?
    lazy var disposeBag = DisposeBag()
    private lazy var webView: WKWebView = {
        let w = WKWebView(frame: .zero)
        w.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        w.navigationDelegate = self
        return w
    }()
    
    private var status: [URLQueryItem]?
    
    private lazy var noItemView = NoItemView(imageName: Config.Error.icon, message: Config.Error.message, on: self.webView) { [unowned self](v) in
        v.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        let s = self.webView.frame.size
        v.frame = CGRect(origin: .zero, size: s)
    }

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        loadURL()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
    }

    deinit {
        guard webView.isLoading else { return }
        webView.stopLoading()
    }
    /// Class's private properties.
}

// MARK: View's event handlers
extension PaymentAddCardVC {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
}

extension PaymentAddCardVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            self.status = components?.queryItems
        }
        printDebug("\(Config.Debug.prefix) \(navigationAction.request)")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        noItemView.attach()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        noItemView.attach()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        defer {
            noItemView.detach()
        }
        
        guard let status = self.status else { return }
        let result = status.reduce([String: String]()) { (temp, query) -> [String: String] in
            var next = temp
            next[query.name] = query.value
            return next
        }
        
        guard  result.value(for: "status", defaultValue: "") == "SUCCESS" else {
            return
        }
        
        self.listener?.paymentAddCardSuccess()
    }
}



// MARK: Class's public methods
extension PaymentAddCardVC {
}

// MARK: Class's private methods
private extension PaymentAddCardVC {
    private func localize() {
        // todo: Localize view's here.
    }
    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.title = Config.title
        let item = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), landscapeImagePhone: #imageLiteral(resourceName: "ic_back").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = item
        item.rx.tap.bind { [weak self] in
            self?.listener?.paymentAddCardMoveBack()
        }.disposed(by: disposeBag)
        
        webView >>> view >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    private func setupRX() {
        // todo: Bind data to UI here.
        let loading = webView.rx
            .observeWeakly(Bool.self, #keyPath(WKWebView.isLoading))
            .filterNil()
        let progress = webView.rx.observeWeakly(Double.self, #keyPath(WKWebView.estimatedProgress)).filterNil()
                
        let loadingProgress = Observable.combineLatest(loading, progress) { (loading, p) -> (Bool, Double) in
            return (loading, p)
        }
        showLoading(use: loadingProgress)
    }
    
    private func loadURL() {
        guard let url = self.listener?.mURL else {
            return
        }
        
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
}

