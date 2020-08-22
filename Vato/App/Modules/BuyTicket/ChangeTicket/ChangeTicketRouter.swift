//  File name   : ChangeTicketRouter.swift
//
//  Author      : MacbookPro
//  Created date: 11/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol ChangeTicketInteractable: Interactable, TicketTimeListener, TicketCalendarListener, TicketBusStationListener, SeatPositionListener, TicketChooseDestinationListener, BuyTicketPaymenListener {
    var router: ChangeTicketRouting? { get set }
    var listener: ChangeTicketListener? { get set }
}

protocol ChangeTicketViewControllable: ViewControllable {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ChangeTicketRouter: ViewableRouter<ChangeTicketInteractable, ChangeTicketViewControllable> {
    /// Class's constructor.
    init(interactor: ChangeTicketInteractable,
         viewController: ChangeTicketViewControllable,
         ticketTimeBuildable: TicketTimeBuildable,
         ticketCalendarBuildable: TicketCalendarBuildable,
         ticketChooseDestinationBuildable: TicketChooseDestinationBuildable,
         ticketBusStationBuildable: TicketBusStationBuildable,
         seatPositionBuildable: SeatPositionBuildable,
         buyTicketPaymentBuildable: BuyTicketPaymentBuildable) {
        
        self.ticketChooseDestinationBuildable = ticketChooseDestinationBuildable
        self.seatPositionBuildable = seatPositionBuildable
        self.ticketBusStationBuildable = ticketBusStationBuildable
        self.ticketTimeBuildable = ticketTimeBuildable
        self.ticketCalendarBuildable = ticketCalendarBuildable
        self.buyTicketPaymentBuildable = buyTicketPaymentBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
        
    }
    
    /// Class's private properties.
    private let ticketTimeBuildable: TicketTimeBuildable
    private let ticketCalendarBuildable: TicketCalendarBuildable
    private let ticketBusStationBuildable: TicketBusStationBuildable
    private let seatPositionBuildable: SeatPositionBuildable
    private let ticketChooseDestinationBuildable: TicketChooseDestinationBuildable
    private let buyTicketPaymentBuildable: BuyTicketPaymentBuildable
}

// MARK: ChangeTicketRouting's members
extension ChangeTicketRouter: ChangeTicketRouting {
    func routeToConfirmPayment(streamType: BuslineStreamType){
        let router = buyTicketPaymentBuildable.build(withListener: interactor, streamType: streamType)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)

    }
    
    func routeToTime(ticketTimeInputModel: TicketTimeInputModel, streamType: BuslineStreamType) {
        let router = ticketTimeBuildable.build(withListener: interactor, ticketTimeInputModel: ticketTimeInputModel, streamType: streamType, ticketRoundTripType: .startTicket)
        let segue = RibsRouting(use: router,
                                transitionType: .modal(type: .crossDissolve, presentStyle: .overCurrentContext),
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToChooseDate(dateSelected: Date?) {
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
    
    func routToBusStop(model: ChooseRouteStopParam, streamType: BuslineStreamType) {
        let router = ticketBusStationBuildable.build(withListener: interactor, viewType: .routeStop, busParam: nil, stopParam: model, streamType: streamType)
        
        let segue = RibsRouting(use: router,
                                transitionType: .push,
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
    
    func routeToStartLocation(startLocation: TicketLocation?) {
        
        let param = ChooseDestinationParam(destinationType: .origin,
                                           originCode: startLocation?.code,
                                           destinationCode: nil)
        let router = ticketChooseDestinationBuildable.build(withListener: interactor,
                                                            param: param)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToDestinationLocation(startLocation: TicketLocation?,
                                    destinationLocation: TicketLocation?) {
        
        let param = ChooseDestinationParam(destinationType: .destination,
                                           originCode: startLocation?.code,
                                           destinationCode: destinationLocation?.code)
        let router = ticketChooseDestinationBuildable.build(withListener: interactor,
                                                            param: param)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension ChangeTicketRouter {
}
