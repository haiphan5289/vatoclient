//  File name   : TicketBusStationRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketBusStationInteractable: Interactable, TicketTimeListener, SeatPositionListener {
    var router: TicketBusStationRouting? { get set }
    var listener: TicketBusStationListener? { get set }
}

protocol TicketBusStationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketBusStationRouter: ViewableRouter<TicketBusStationInteractable, TicketBusStationViewControllable> {
    /// Class's constructor.
    init(interactor: TicketBusStationInteractable,
         viewController: TicketBusStationViewControllable,
         ticketTimeBuildable: TicketTimeBuildable,
         seatPositionBuildable: SeatPositionBuildable) {
        self.seatPositionBuildable = seatPositionBuildable
        self.ticketTimeBuildable = ticketTimeBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var ticketTimeBuildable: TicketTimeBuildable
    private var seatPositionBuildable: SeatPositionBuildable
}

// MARK: TicketBusStationRouting's members
extension TicketBusStationRouter: TicketBusStationRouting {
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType) {
        let router = ticketTimeBuildable.build(withListener: interactor,
                                               ticketTimeInputModel: ticketTimeInputModel,
                                               streamType: streamType, ticketRoundTripType: .startTicket)
        let segue = RibsRouting(use: router,
                                transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext),
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routToSeatPosition(chooseSeatParam: ChooseSeatParam, streamType: BuslineStreamType) {
        let router = seatPositionBuildable.build(withListener: interactor, seatParam: chooseSeatParam, streamType: streamType, type: .startTicket)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension TicketBusStationRouter {
}
