//  File name   : ListProductRouter.swift
//
//  Author      : khoi tran
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ListProductInteractable: Interactable, AddProductListener {
    var router: ListProductRouting? { get set }
    var listener: ListProductListener? { get set }
}

protocol ListProductViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ListProductRouter: ViewableRouter<ListProductInteractable, ListProductViewControllable> {
    /// Class's constructor.
    init(interactor: ListProductInteractable, viewController: ListProductViewControllable, addProductBuildable: AddProductBuildable) {
        self.addProductBuildable = addProductBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let addProductBuildable: AddProductBuildable

}

// MARK: ListProductRouting's members
extension ListProductRouter: ListProductRouting {
    func routeToProductDetail(currentProduct: DisplayProduct?) {
        let route = addProductBuildable.build(withListener: interactor, currentProduct: currentProduct)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension ListProductRouter {
}
