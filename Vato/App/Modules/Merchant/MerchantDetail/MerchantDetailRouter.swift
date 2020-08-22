//  File name   : MerchantDetailRouter.swift
//
//  Author      : khoi tran
//  Created date: 10/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol MerchantDetailInteractable: Interactable, AddStoreListener, CreateMerchantDetailListener, StoreDetailListener {
    var router: MerchantDetailRouting? { get set }
    var listener: MerchantDetailListener? { get set }
    func refresh()
}

protocol MerchantDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class MerchantDetailRouter: ViewableRouter<MerchantDetailInteractable, MerchantDetailViewControllable> {
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
    
    /// Class's constructor.
    init(interactor: MerchantDetailInteractable,
         viewController: MerchantDetailViewControllable,
         addStroreBuildable: AddStoreBuildable,
         createMerchantDetailBuildable: CreateMerchantDetailBuildable,
         storeDetailBuildable: StoreDetailBuildable) {
        self.addStroreBuildable = addStroreBuildable
        self.createMerchantDetailBuildable = createMerchantDetailBuildable
        self.storeDetailBuildable = storeDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let addStroreBuildable: AddStoreBuildable
    private let createMerchantDetailBuildable: CreateMerchantDetailBuildable
    private let storeDetailBuildable: StoreDetailBuildable

}

// MARK: MerchantDetailRouting's members
extension MerchantDetailRouter: MerchantDetailRouting {
    
    func routeToAddStore() {
        let route = addStroreBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToCreateMerchantDetail() {
        let route = createMerchantDetailBuildable.build(withListener: interactor, category: nil)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToStoreDetail() {
        let route = storeDetailBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
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
private extension MerchantDetailRouter {
}
