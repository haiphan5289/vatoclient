//  File name   : TicketCalendarRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketCalendarInteractable: Interactable {
    var router: TicketCalendarRouting? { get set }
    var listener: TicketCalendarListener? { get set }
}

protocol TicketCalendarViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketCalendarRouter: ViewableRouter<TicketCalendarInteractable, TicketCalendarViewControllable> {
    /// Class's constructor.
    override init(interactor: TicketCalendarInteractable, viewController: TicketCalendarViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
}

// MARK: TicketCalendarRouting's members
extension TicketCalendarRouter: TicketCalendarRouting {
    
}

// MARK: Class's private methods
private extension TicketCalendarRouter {
}
