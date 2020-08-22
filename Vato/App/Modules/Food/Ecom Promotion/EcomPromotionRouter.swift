//  File name   : EcomPromotionRouter.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol EcomPromotionInteractable: Interactable {
    var router: EcomPromotionRouting? { get set }
    var listener: EcomPromotionListener? { get set }
}

protocol EcomPromotionViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class EcomPromotionRouter: ViewableRouter<EcomPromotionInteractable, EcomPromotionViewControllable> {
    /// Class's constructor.
    override init(interactor: EcomPromotionInteractable, viewController: EcomPromotionViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: EcomPromotionRouting's members
extension EcomPromotionRouter: EcomPromotionRouting {
    
}

// MARK: Class's private methods
private extension EcomPromotionRouter {
}
