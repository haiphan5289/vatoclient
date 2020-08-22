//  File name   : TicketChooseDestinationRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketChooseDestinationInteractable: Interactable {
    var router: TicketChooseDestinationRouting? { get set }
    var listener: TicketChooseDestinationListener? { get set }
}

protocol TicketChooseDestinationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketChooseDestinationRouter: ViewableRouter<TicketChooseDestinationInteractable, TicketChooseDestinationViewControllable> {
    /// Class's constructor.
    override init(interactor: TicketChooseDestinationInteractable, viewController: TicketChooseDestinationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TicketChooseDestinationRouting's members
extension TicketChooseDestinationRouter: TicketChooseDestinationRouting {
    
}

// MARK: Class's private methods
private extension TicketChooseDestinationRouter {
}
