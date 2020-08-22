//  File name   : ConfirmBookingServiceMoreRouter.swift
//
//  Author      : MacbookPro
//  Created date: 11/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ConfirmBookingServiceMoreInteractable: Interactable {
    var router: ConfirmBookingServiceMoreRouting? { get set }
    var listener: ConfirmBookingServiceMoreListener? { get set }
}

protocol ConfirmBookingServiceMoreViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ConfirmBookingServiceMoreRouter: ViewableRouter<ConfirmBookingServiceMoreInteractable, ConfirmBookingServiceMoreViewControllable> {
    /// Class's constructor.
    override init(interactor: ConfirmBookingServiceMoreInteractable, viewController: ConfirmBookingServiceMoreViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: ConfirmBookingServiceMoreRouting's members
extension ConfirmBookingServiceMoreRouter: ConfirmBookingServiceMoreRouting {
    
}

// MARK: Class's private methods
private extension ConfirmBookingServiceMoreRouter {
}
