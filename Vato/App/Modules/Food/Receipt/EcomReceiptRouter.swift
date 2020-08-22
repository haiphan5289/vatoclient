//  File name   : EcomReceiptRouter.swift
//
//  Author      : Dung Vu
//  Created date: 3/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol EcomReceiptInteractable: Interactable {
    var router: EcomReceiptRouting? { get set }
    var listener: EcomReceiptListener? { get set }
}

protocol EcomReceiptViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class EcomReceiptRouter: ViewableRouter<EcomReceiptInteractable, EcomReceiptViewControllable> {
    /// Class's constructor.
    override init(interactor: EcomReceiptInteractable, viewController: EcomReceiptViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: EcomReceiptRouting's members
extension EcomReceiptRouter: EcomReceiptRouting {
    
}

// MARK: Class's private methods
private extension EcomReceiptRouter {
}
