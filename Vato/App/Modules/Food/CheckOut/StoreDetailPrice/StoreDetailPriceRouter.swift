//  File name   : StoreDetailPriceRouter.swift
//
//  Author      : khoi tran
//  Created date: 12/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol StoreDetailPriceInteractable: Interactable {
    var router: StoreDetailPriceRouting? { get set }
    var listener: StoreDetailPriceListener? { get set }
}

protocol StoreDetailPriceViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class StoreDetailPriceRouter: ViewableRouter<StoreDetailPriceInteractable, StoreDetailPriceViewControllable> {
    /// Class's constructor.
    override init(interactor: StoreDetailPriceInteractable, viewController: StoreDetailPriceViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: StoreDetailPriceRouting's members
extension StoreDetailPriceRouter: StoreDetailPriceRouting {
    
}

// MARK: Class's private methods
private extension StoreDetailPriceRouter {
}
