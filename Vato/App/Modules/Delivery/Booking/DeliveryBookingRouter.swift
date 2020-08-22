//  File name   : DeliveryBookingRouter.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol DeliveryBookingInteractable: Interactable {
    var router: DeliveryBookingRouting? { get set }
    var listener: DeliveryBookingListener? { get set }
}

protocol DeliveryBookingViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DeliveryBookingRouter: ViewableRouter<DeliveryBookingInteractable, DeliveryBookingViewControllable> {
    /// Class's constructor.
    override init(interactor: DeliveryBookingInteractable, viewController: DeliveryBookingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: DeliveryBookingRouting's members
extension DeliveryBookingRouter: DeliveryBookingRouting {
    
}

// MARK: Class's private methods
private extension DeliveryBookingRouter {
}
