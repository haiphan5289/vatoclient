//  File name   : ResultBuyTicketRouter.swift
//
//  Author      : vato.
//  Created date: 10/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ResultBuyTicketInteractable: Interactable, TicketDetailRouteListener {
    var router: ResultBuyTicketRouting? { get set }
    var listener: ResultBuyTicketListener? { get set }
}

protocol ResultBuyTicketViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ResultBuyTicketRouter: ViewableRouter<ResultBuyTicketInteractable, ResultBuyTicketViewControllable> {
    /// Class's constructor.
    init(interactor: ResultBuyTicketInteractable,
         viewController: ResultBuyTicketViewControllable,
         ticketDetailRouteBuildable: TicketDetailRouteBuildable) {
        self.ticketDetailRouteBuildable = ticketDetailRouteBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let ticketDetailRouteBuildable: TicketDetailRouteBuildable
}

// MARK: ResultBuyTicketRouting's members
extension ResultBuyTicketRouter: ResultBuyTicketRouting {
    func routeToTicketRouteDetail(_ info: DetailRouteInfo) {
        let route = ticketDetailRouteBuildable.build(withListener: interactor, item: info)
        let segue = RibsRouting(use: route, transitionType: .push, needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension ResultBuyTicketRouter {
}
