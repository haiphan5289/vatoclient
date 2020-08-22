//  File name   : TransportServiceRouter.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TransportServiceInteractable: Interactable {
    var router: TransportServiceRouting? { get set }
    var listener: TransportServiceListener? { get set }
}

protocol TransportServiceViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TransportServiceRouter: ViewableRouter<TransportServiceInteractable, TransportServiceViewControllable>, TransportServiceRouting {
    // todo: Constructor inject child builder protocols to allow building children.
    override init(interactor: TransportServiceInteractable, viewController: TransportServiceViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
