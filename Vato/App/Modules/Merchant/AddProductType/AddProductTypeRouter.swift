//  File name   : AddProductTypeRouter.swift
//
//  Author      : khoi tran
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol AddProductTypeInteractable: Interactable {
    var router: AddProductTypeRouting? { get set }
    var listener: AddProductTypeListener? { get set }
}

protocol AddProductTypeViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class AddProductTypeRouter: ViewableRouter<AddProductTypeInteractable, AddProductTypeViewControllable> {
    /// Class's constructor.
    override init(interactor: AddProductTypeInteractable, viewController: AddProductTypeViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: AddProductTypeRouting's members
extension AddProductTypeRouter: AddProductTypeRouting {
    
}

// MARK: Class's private methods
private extension AddProductTypeRouter {
}
