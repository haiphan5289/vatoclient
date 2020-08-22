//  File name   : MainMerchantRouter.swift
//
//  Author      : khoi tran
//  Created date: 10/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol MainMerchantInteractable: Interactable, MerchantDetailListener, CreateMerchantTypeListener {
    var router: MainMerchantRouting? { get set }
    var listener: MainMerchantListener? { get set }
    
    func refresh()
}

protocol MainMerchantViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MainMerchantRouter: ViewableRouter<MainMerchantInteractable, MainMerchantViewControllable> {
    /// Class's constructor.
    struct Configs {
        static let rootMerchantURL: String = {
            #if DEBUG
                return "https://tracking-dev.vato.vn/cua-hang"
            #else
                return "https://tracking.vato.vn/cua-hang"
            #endif
        }()
        
        static let formatMerchantURL: String = {
            let u: String = rootMerchantURL
            return u + "?token=%@"
        }()
        
        static let merchantEditURL: (_ idMerchant: String, _ token: String) -> String = { (id, token) -> String in
            return rootMerchantURL + "/\(id)" + "?token=\(token)"
        }
    }
    
    init(interactor: MainMerchantInteractable,
         viewController: MainMerchantViewControllable,
         merchantDetailBuildable: MerchantDetailBuildable,
         createMerchantTypeBuildable: CreateMerchantTypeBuildable) {
        self.merchantDetailBuildable = merchantDetailBuildable
        self.createMerchantTypeBuildable = createMerchantTypeBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let merchantDetailBuildable: MerchantDetailBuildable
    private let createMerchantTypeBuildable: CreateMerchantTypeBuildable

}

// MARK: MainMerchantRouting's members
extension MainMerchantRouter: MainMerchantRouting {
    func routeToMerchantDetail() {
        let route = merchantDetailBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
        
    }
    
    func routeToCreateMerchantType() {
        let route = createMerchantTypeBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToWebMerchant(token: String) {
        let p = String(format: Configs.formatMerchantURL, token)
        WebHandlerVC.loadWebCustom(on: self.viewControllable.uiviewController, url: URL(string: p), title: nil, type: .default) { (controller, url) in
            guard let url = url else { return }
            guard url.absoluteString.contains("thanh-cong") else { return }
            controller?.dismiss(animated: true, completion: { [weak self] in
                self?.interactor.refresh()
            })
        }
    }
    
    func routeToEditMerchant(idMerchant: String, token: String) {
        let p = Configs.merchantEditURL(idMerchant, token)
        WebHandlerVC.loadWebCustom(on: self.viewControllable.uiviewController, url: URL(string: p), title: nil, type: .default) { (controller, url) in
            guard let url = url, url.absoluteString.contains("thanh-cong") else { return }
            controller?.dismiss(animated: true, completion: { [weak self] in
                self?.interactor.refresh()
            })
        }
    }
}

// MARK: Class's private methods
private extension MainMerchantRouter {
    
}
