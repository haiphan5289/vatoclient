//  File name   : TicketHistoryRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketHistoryInteractable: Interactable, CancelTicketListener, TicketHistoryDetailListener, ChangeTicketListener, TicketDetailRouteListener {
    var router: TicketHistoryRouting? { get set }
    var listener: TicketHistoryListener? { get set }
}

protocol TicketHistoryViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketHistoryRouter: ViewableRouter<TicketHistoryInteractable, TicketHistoryViewControllable> {
    /// Class's constructor.
    init(interactor: TicketHistoryInteractable,
         viewController: TicketHistoryViewControllable,
         cancelTicketBuildable: CancelTicketBuildable,
         ticketHistoryDetailBuildable: TicketHistoryDetailBuildable,
         changeTicketBuildable: ChangeTicketBuildable,
         ticketDetailRouteBuildable: TicketDetailRouteBuildable) {
        self.ticketHistoryDetailBuildable = ticketHistoryDetailBuildable
        self.changeTicketBuildable = changeTicketBuildable
        self.cancelTicketBuildable = cancelTicketBuildable
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
    private let ticketHistoryDetailBuildable: TicketHistoryDetailBuildable
    private let ticketDetailRouteBuildable: TicketDetailRouteBuildable
}

// MARK: TicketHistoryRouting's members
extension TicketHistoryRouter: TicketHistoryRouting {
    func routeToTicketRouteDetail(_ info: DetailRouteInfo) {
        let route = ticketDetailRouteBuildable.build(withListener: interactor, item: info)
        let segue = RibsRouting(use: route, transitionType: .push, needRemoveCurrent: true )
        perform(with: segue, completion: nil)
    }
    
    func routeToCancel(item: TicketHistoryType) {
        let router = cancelTicketBuildable.build(withListener: interactor, item: item)
        let segue = RibsRouting(use: router,
                                transitionType: .presentNavigation,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToDetail(item: TicketHistoryType) {
        let router = ticketHistoryDetailBuildable.build(withListener: interactor, ticketHistoryType: item)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToChangeTicket(item: TicketHistoryType) {
        let router = changeTicketBuildable.build(withListener: interactor, model: item)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension TicketHistoryRouter {
}
