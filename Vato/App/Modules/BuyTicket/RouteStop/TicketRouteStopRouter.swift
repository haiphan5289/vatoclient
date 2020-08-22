//  File name   : TicketRouteStopRouter.swift
//
//  Author      : khoi tran
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketRouteStopInteractable: Interactable {
    var router: TicketRouteStopRouting? { get set }
    var listener: TicketRouteStopListener? { get set }
}

protocol TicketRouteStopViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketRouteStopRouter: ViewableRouter<TicketRouteStopInteractable, TicketRouteStopViewControllable> {
    /// Class's constructor.
    override init(interactor: TicketRouteStopInteractable, viewController: TicketRouteStopViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TicketRouteStopRouting's members
extension TicketRouteStopRouter: TicketRouteStopRouting {
    
}

// MARK: Class's private methods
private extension TicketRouteStopRouter {
}
