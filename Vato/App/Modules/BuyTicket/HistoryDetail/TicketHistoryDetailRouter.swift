//  File name   : TicketHistoryDetailRouter.swift
//
//  Author      : vato.
//  Created date: 10/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketHistoryDetailInteractable: Interactable, CancelTicketListener, ChangeTicketListener, TicketDetailRouteListener {
    var router: TicketHistoryDetailRouting? { get set }
    var listener: TicketHistoryDetailListener? { get set }
}

protocol TicketHistoryDetailViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketHistoryDetailRouter: ViewableRouter<TicketHistoryDetailInteractable, TicketHistoryDetailViewControllable> {
    /// Class's constructor.
    init(interactor: TicketHistoryDetailInteractable,
         viewController: TicketHistoryDetailViewControllable,
         cancelTicketBuildable: CancelTicketBuildable,
         changeTicketBuildable: ChangeTicketBuildable,
         ticketDetailRouteBuildable: TicketDetailRouteBuildable) {
        self.cancelTicketBuildable = cancelTicketBuildable
        self.changeTicketBuildable = changeTicketBuildable
        self.ticketDetailRouteBuildable = ticketDetailRouteBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private let cancelTicketBuildable: CancelTicketBuildable
    private let changeTicketBuildable: ChangeTicketBuildable
    private let ticketDetailRouteBuildable: TicketDetailRouteBuildable
}

// MARK: TicketHistoryDetailRouting's members
extension TicketHistoryDetailRouter: TicketHistoryDetailRouting {
    func routeToTicketRouteDetail(_ info: DetailRouteInfo) {
        let route = ticketDetailRouteBuildable.build(withListener: interactor, item: info)
        let segue = RibsRouting(use: route, transitionType: .push, needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToChangeTicket(item: TicketHistoryType) {
        let router = changeTicketBuildable.build(withListener: interactor, model: item)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
        
    }
    func routeToCancel(item: TicketHistoryType) {
        let router = cancelTicketBuildable.build(withListener: interactor, item: item)
        let segue = RibsRouting(use: router,
                                transitionType: .presentNavigation,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension TicketHistoryDetailRouter {
}
