//  File name   : TicketDetailRouteRouter.swift
//
//  Author      : MacbookPro
//  Created date: 5/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketDetailRouteInteractable: Interactable {
    var router: TicketDetailRouteRouting? { get set }
    var listener: TicketDetailRouteListener? { get set }
}

protocol TicketDetailRouteViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketDetailRouteRouter: ViewableRouter<TicketDetailRouteInteractable, TicketDetailRouteViewControllable> {
    /// Class's constructor.
    override init(interactor: TicketDetailRouteInteractable, viewController: TicketDetailRouteViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TicketDetailRouteRouting's members
extension TicketDetailRouteRouter: TicketDetailRouteRouting {
    
}

// MARK: Class's private methods
private extension TicketDetailRouteRouter {
}
