//  File name   : ProductMenuRouter.swift
//
//  Author      : khoi tran
//  Created date: 12/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ProductMenuInteractable: Interactable {
    var router: ProductMenuRouting? { get set }
    var listener: ProductMenuListener? { get set }
}

protocol ProductMenuViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProductMenuRouter: ViewableRouter<ProductMenuInteractable, ProductMenuViewControllable> {
    /// Class's constructor.
    override init(interactor: ProductMenuInteractable, viewController: ProductMenuViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ProductMenuRouting's members
extension ProductMenuRouter: ProductMenuRouting {
    
}

// MARK: Class's private methods
private extension ProductMenuRouter {
}
