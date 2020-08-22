//  File name   : StoreDetailRouter.swift
//
//  Author      : khoi tran
//  Created date: 11/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol StoreDetailInteractable: Interactable, AddProductListener, AddStoreListener, ListProductListener {
    var router: StoreDetailRouting? { get set }
    var listener: StoreDetailListener? { get set }
}

protocol StoreDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class StoreDetailRouter: ViewableRouter<StoreDetailInteractable, StoreDetailViewControllable> {
    /// Class's constructor.
    init(interactor: StoreDetailInteractable,
         viewController: StoreDetailViewControllable,
         addProductBuildable: AddProductBuildable,
         addStoreBuildable: AddStoreBuildable,
         listProductBuildable: ListProductBuildable) {
        self.addProductBuildable = addProductBuildable
        self.addStoreBuildable = addStoreBuildable
        self.listProductBuildable = listProductBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let addProductBuildable: AddProductBuildable
    private let addStoreBuildable: AddStoreBuildable
    private let listProductBuildable: ListProductBuildable

}

// MARK: StoreDetailRouting's members
extension StoreDetailRouter: StoreDetailRouting {
    func routeToProductDetail(currentProduct: DisplayProduct?) {
        let route = addProductBuildable.build(withListener: interactor, currentProduct: currentProduct)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    
    func routeToAddStore() {
        let route = addStoreBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToListProduct() {
        let route = listProductBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    
}

// MARK: Class's private methods
private extension StoreDetailRouter {
}
