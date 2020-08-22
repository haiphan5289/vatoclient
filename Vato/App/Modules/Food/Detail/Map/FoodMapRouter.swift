//  File name   : FoodMapRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/31/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol FoodMapInteractable: Interactable {
    var router: FoodMapRouting? { get set }
    var listener: FoodMapListener? { get set }
}

protocol FoodMapViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class FoodMapRouter: ViewableRouter<FoodMapInteractable, FoodMapViewControllable> {
    /// Class's constructor.
    override init(interactor: FoodMapInteractable, viewController: FoodMapViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: FoodMapRouting's members
extension FoodMapRouter: FoodMapRouting {
    
}

// MARK: Class's private methods
private extension FoodMapRouter {
}
