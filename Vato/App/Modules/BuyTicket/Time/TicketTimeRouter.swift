//  File name   : TicketTimeRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketTimeInteractable: Interactable, TicketBusStationListener {
    var router: TicketTimeRouting? { get set }
    var listener: TicketTimeListener? { get set }
}

protocol TicketTimeViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketTimeRouter: ViewableRouter<TicketTimeInteractable, TicketTimeViewControllable> {
    /// Class's constructor.
    init(interactor: TicketTimeInteractable,
         viewController: TicketTimeViewControllable,
         ticketBusStationBuildable: TicketBusStationBuildable) {
        self.ticketBusStationBuildable = ticketBusStationBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var ticketBusStationBuildable: TicketBusStationBuildable
}

// MARK: TicketTimeRouting's members
extension TicketTimeRouter: TicketTimeRouting {
    func routToBusStop(model: ChooseRouteStopParam, streamType: BuslineStreamType) {
        let router = ticketBusStationBuildable.build(withListener: interactor, viewType: .routeStop, busParam: nil, stopParam: model, streamType: streamType)
        
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension TicketTimeRouter {
}
