//  File name   : TicketFillInformationRouter.swift
//
//  Author      : khoi tran
//  Created date: 4/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketFillInformationInteractable: Interactable, TicketTimeListener, TicketRouteStopListener, SeatPositionListener {
    var router: TicketFillInformationRouting? { get set }
    var listener: TicketFillInformationListener? { get set }
}

protocol TicketFillInformationViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketFillInformationRouter: ViewableRouter<TicketFillInformationInteractable, TicketFillInformationViewControllable> {
    /// Class's constructor.
    init(interactor: TicketFillInformationInteractable, viewController: TicketFillInformationViewControllable,
         ticketTimeBuildable: TicketTimeBuildable,
         ticketRouteStopBuildable: TicketRouteStopBuildable,
         seatPositionBuildable: SeatPositionBuildable) {
        self.ticketTimeBuildable = ticketTimeBuildable
        self.ticketRouteStopBuildable = ticketRouteStopBuildable
        self.seatPositionBuildable = seatPositionBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var ticketTimeBuildable: TicketTimeBuildable
    private var ticketRouteStopBuildable: TicketRouteStopBuildable
    private var seatPositionBuildable: SeatPositionBuildable

}

// MARK: TicketFillInformationRouting's members
extension TicketFillInformationRouter: TicketFillInformationRouting {
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType, ticketRoundTripType: TicketRoundTripType) {
        let router = ticketTimeBuildable.build(withListener: interactor,
                                               ticketTimeInputModel: ticketTimeInputModel,
                                               streamType: streamType, ticketRoundTripType: ticketRoundTripType)
        let segue = RibsRouting(use: router,
                                transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext),
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToRouteStop(routeStopParam: ChooseRouteStopParam?, currentRouteStopId: Int?, listRouteStop: [RouteStop]?) {
        let route = ticketRouteStopBuildable.build(withListener: interactor, routeStopParam: routeStopParam, currentRouteStopId: currentRouteStopId, listRouteStop: listRouteStop)
        let segue = RibsRouting(use: route, transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext), needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routToSeatPosition(chooseSeatParam: ChooseSeatParam, streamType: BuslineStreamType, type: TicketRoundTripType) {
        let router = seatPositionBuildable.build(withListener: interactor, seatParam: chooseSeatParam, streamType: streamType, type: type)
        let segue = RibsRouting(use: router,
                                transitionType: .modal(type: .coverVertical, presentStyle: .overCurrentContext),
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension TicketFillInformationRouter {
}
