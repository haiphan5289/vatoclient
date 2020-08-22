//  File name   : TicketDetailRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketDetailInteractable: Interactable {
    var router: TicketDetailRouting? { get set }
    var listener: TicketDetailListener? { get set }
}

protocol TicketDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketDetailRouter: ViewableRouter<TicketDetailInteractable, TicketDetailViewControllable> {
    /// Class's constructor.
    override init(interactor: TicketDetailInteractable, viewController: TicketDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TicketDetailRouting's members
extension TicketDetailRouter: TicketDetailRouting {
    
}

// MARK: Class's private methods
private extension TicketDetailRouter {
}
