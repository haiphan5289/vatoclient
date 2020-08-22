//  File name   : BookingRequestRouter.swift
//
//  Author      : Dung Vu
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol BookingRequestInteractable: Interactable {
    var router: BookingRequestRouting? { get set }
    var listener: BookingRequestListener? { get set }
}

protocol BookingRequestViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class BookingRequestRouter: ViewableRouter<BookingRequestInteractable, BookingRequestViewControllable>, BookingRequestRouting {

    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: BookingRequestInteractable, viewController: BookingRequestViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
