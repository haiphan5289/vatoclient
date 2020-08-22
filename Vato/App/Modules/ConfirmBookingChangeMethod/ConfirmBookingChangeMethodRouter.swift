//  File name   : ConfirmBookingChangeMethodRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ConfirmBookingChangeMethodInteractable: Interactable {
    var router: ConfirmBookingChangeMethodRouting? { get set }
    var listener: ConfirmBookingChangeMethodListener? { get set }
}

protocol ConfirmBookingChangeMethodViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ConfirmBookingChangeMethodRouter: ViewableRouter<ConfirmBookingChangeMethodInteractable, ConfirmBookingChangeMethodViewControllable>, ConfirmBookingChangeMethodRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: ConfirmBookingChangeMethodInteractable, viewController: ConfirmBookingChangeMethodViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
