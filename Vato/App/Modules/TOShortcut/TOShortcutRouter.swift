//  File name   : TOShortcutRouter.swift
//
//  Author      : khoi tran
//  Created date: 2/17/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TOShortcutInteractable: Interactable, WalletListHistoryListener, HistoryListener, QuickSupportMainListener, MainMerchantListener, ReferralListener, SetLocationListener {
    var router: TOShortcutRouting? { get set }
    var listener: TOShortcutListener? { get set }
    
    func routeToItem(item: TOShortutModel)
}

protocol TOShortcutViewControllable: ViewControllable  {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TOShortcutRouter: ViewableRouter<TOShortcutInteractable, TOShortcutViewControllable> {
    /// Class's constructor.
    struct Configs {
        static let formatMerchantURL: String = {
            let u: String
            #if DEBUG
                u = "https://tracking-dev.vato.vn/cua-hang"
            #else
                u = "https://tracking.vato.vn/cua-hang"
            #endif
            return u + "?token=%@"
        }()
    }
    
    init(interactor: TOShortcutInteractable,
         viewController: TOShortcutViewControllable,
         walletListHistoryBuildable: WalletListHistoryBuildable,
         historyBuildable: HistoryBuildable,
         quickSupportMainBuildable: QuickSupportMainBuildable,
         mainMerchantBuildable: MainMerchantBuildable,
         referralBuildable: ReferralBuildable,
         setLocationBuildable: SetLocationBuildable) {
        self.setLocationBuildable = setLocationBuildable
        self.walletListHistoryBuildable = walletListHistoryBuildable
        self.historyBuildable = historyBuildable
        self.quickSupportMainBuildable = quickSupportMainBuildable
        self.mainMerchantBuildable = mainMerchantBuildable
        self.referralBuildable = referralBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let walletListHistoryBuildable: WalletListHistoryBuildable
    private let historyBuildable: HistoryBuildable
    private let quickSupportMainBuildable: QuickSupportMainBuildable
    private let mainMerchantBuildable: MainMerchantBuildable
    private let referralBuildable: ReferralBuildable
    private let setLocationBuildable: SetLocationBuildable
}

// MARK: TOShortcutRouting's members
extension TOShortcutRouter: TOShortcutRouting {
    func routeToReferral() {
        let router = referralBuildable.build(withListener: self.interactor)
        let transition = RibsRouting(use: router, transitionType: .presentNavigation, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToSetLocation() {
        let route = setLocationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .coverVertical, presentStyle: .fullScreen) , needRemoveCurrent: false )
        perform(with: segue, completion: nil)
    }
    
    func routeToWalletListHistory() {
        let router = walletListHistoryBuildable.build(withListener: self.interactor, balanceType: 3)
        let transition = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToHistory() {
        let router = historyBuildable.build(withListener: self.interactor, selected: nil)
        let transition = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToQuickSupport() {
        let router = quickSupportMainBuildable.build(withListener: self.interactor)
        let transition = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToMerchant() {
        let router = mainMerchantBuildable.build(withListener: self.interactor)
        let transition = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        self.perform(with: transition, completion: nil)
    }
    
    func routeToSOS() {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Call #1900 6667", style: .default, handler: { (action) -> Void in
            if let url = URL(string: "tel://\(19006667)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Call #113", style: .default, handler: { (action) -> Void in
            if let url = URL(string: "tel://\(113)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        actionsheet.addAction(UIAlertAction(title: Text.cancel.localizedText, style: .cancel, handler: { (action) -> Void in
        }))
        
        self.viewControllable.uiviewController.present(actionsheet, animated: true, completion: nil)
    }
    
    func routeToWebMerchant(token: String) {
        let p = String(format: Configs.formatMerchantURL, token)
        WebHandlerVC.loadWebCustom(on: self.viewControllable.uiviewController, url: URL(string: p), title: nil, type: .default) { (controller, url) in
            guard let url = url, url.absoluteString.contains("thanh-cong") else { return }
            controller?.dismiss(animated: true, completion: { [weak self] in
                self?.interactor.routeToItem(item: TOShortutModel(cellType: .normal, type: .merchant))
            })
        }
    }
}

// MARK: Class's private methods
private extension TOShortcutRouter {
}
