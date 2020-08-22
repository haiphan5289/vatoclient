//  File name   : ConfirmBuyTicketRouter.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ConfirmBuyTicketInteractable: Interactable, BuyTicketPaymenListener, TicketCalendarListener, TicketTimeListener, TicketBusStationListener {
    var router: ConfirmBuyTicketRouting? { get set }
    var listener: ConfirmBuyTicketListener? { get set }
}

protocol ConfirmBuyTicketViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ConfirmBuyTicketRouter: ViewableRouter<ConfirmBuyTicketInteractable, ConfirmBuyTicketViewControllable> {
    /// Class's constructor.
    init(interactor: ConfirmBuyTicketInteractable,
         viewController: ConfirmBuyTicketViewControllable,
         buyTicketPaymentBuildable: BuyTicketPaymentBuildable,
        ticketCalendarBuildable: TicketCalendarBuildable,
        ticketTimeBuildable: TicketTimeBuildable,
        seatPositionBuildable: SeatPositionBuildable,
        ticketBusStationBuildable: TicketBusStationBuildable ) {
        self.ticketCalendarBuildable = ticketCalendarBuildable
        self.ticketTimeBuildable = ticketTimeBuildable
        self.seatPositionBuildable = seatPositionBuildable
        self.ticketBusStationBuildable = ticketBusStationBuildable
        self.buyTicketPaymentBuildable = buyTicketPaymentBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    private var buyTicketPaymentBuildable: BuyTicketPaymentBuildable
    private var ticketCalendarBuildable: TicketCalendarBuildable
    private var ticketTimeBuildable: TicketTimeBuildable
    private var seatPositionBuildable: SeatPositionBuildable
    private var ticketBusStationBuildable: TicketBusStationBuildable
}

// MARK: ConfirmBuyTicketRouting's members
extension ConfirmBuyTicketRouter: ConfirmBuyTicketRouting {
    func routeToBuyTicketPayment(streamType: BuslineStreamType) {
        let router = buyTicketPaymentBuildable.build(withListener: interactor, streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }

    func routeSelectDate(dateSelected: Date?) {
        let router = ticketCalendarBuildable.build(withListener: interactor, dateSelected: dateSelected, ticketType: .startTicket)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToBusStation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType) {
        let model = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
        let router = ticketBusStationBuildable.build(withListener: interactor, viewType: .ticketRoute, busParam: model, stopParam: nil, streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType) {
        let router = ticketTimeBuildable.build(withListener: interactor,
                                               ticketTimeInputModel: ticketTimeInputModel,
                                               streamType: streamType, ticketRoundTripType: .startTicket)
        let segue = RibsRouting(use: router,
                                transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext),
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeSelectBusStop() {
//        let router = ticketBusStationBuildable.build(withListener: interactor)
//        let segue = RibsRouting(use: router,
//                                transitionType: .push,
//                                needRemoveCurrent: false)
//        perform(with: segue, completion: nil)
    }
    
    func routeSelectSeats() {
//        let router = seatPositionBuildable.build(withListener: interactor)
//        let segue = RibsRouting(use: router,
//                                transitionType: .push,
//                                needRemoveCurrent: false)
//        perform(with: segue, completion: nil)
    }
    
}

// MARK: Class's private methods
private extension ConfirmBuyTicketRouter {
}
