//  File name   : TicketDestinationRouter.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

protocol TicketDestinationInteractable: Interactable, TicketChooseDestinationListener, TicketCalendarListener, TicketBusStationListener, TicketUserInfomationListener, TicketHistoryListener, TicketHistoryDetailListener, 
    TicketFillInformationListener, TicketMainFillInformationListener, TicketDetailRouteListener {
    var router: TicketDestinationRouting? { get set }
    var listener: TicketDestinationListener? { get set }
}

protocol TicketDestinationViewControllable: ViewControllable, ControllableProtocol {
    // todo: Declare methods the router invokes to manipulate the view hierarchy.
}

final class TicketDestinationRouter: ViewableRouter<TicketDestinationInteractable, TicketDestinationViewControllable> {
    /// Class's constructor.
    init(interactor: TicketDestinationInteractable,
         viewController: TicketDestinationViewControllable,
         ticketChooseDestinationBuildable: TicketChooseDestinationBuildable,
         ticketCalendarBuildable: TicketCalendarBuildable,
         ticketUserInfomationBuildable: TicketUserInfomationBuilder,
         ticketHistoryBuildable: TicketHistoryBuildable,
         ticketHistoryDetailBuildable: TicketHistoryDetailBuildable,
         ticketFillInformationBuildable: TicketFillInformationBuildable,
         ticketMainFillInformationBuildable: TicketMainFillInformationBuildable,
         ticketDetailRouteBuildable: TicketDetailRouteBuildable) {
        self.ticketHistoryBuildable = ticketHistoryBuildable
        self.ticketChooseDestinationBuildable = ticketChooseDestinationBuildable
        self.ticketCalendarBuildable = ticketCalendarBuildable
        self.ticketUserInfomationBuildable = ticketUserInfomationBuildable
        self.ticketHistoryDetailBuildable = ticketHistoryDetailBuildable
        self.ticketFillInformationBuildable = ticketFillInformationBuildable
        self.ticketMainFillInformationBuildable = ticketMainFillInformationBuildable
        self.mViewController = viewController
        self.ticketDetailRouteBuildable = ticketDetailRouteBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: Class's public methods
    override func didLoad() {
        super.didLoad()
    }
    
    /// Class's private properties.
    
    private weak var currentRouting: ViewableRouting?
    private let mViewController: TicketDestinationViewControllable

    private let ticketChooseDestinationBuildable: TicketChooseDestinationBuildable
    private let ticketCalendarBuildable: TicketCalendarBuildable
    private let ticketUserInfomationBuildable: TicketUserInfomationBuildable
    private let ticketHistoryBuildable: TicketHistoryBuildable
    private let ticketHistoryDetailBuildable: TicketHistoryDetailBuildable
    private let ticketFillInformationBuildable: TicketFillInformationBuildable
    private let ticketMainFillInformationBuildable: TicketMainFillInformationBuildable
    private let ticketDetailRouteBuildable: TicketDetailRouteBuildable
}

// MARK: TicketDestinationRouting's members
extension TicketDestinationRouter: TicketDestinationRouting {
    
    func routeToTicketMainFillInformation() {
        let router = ticketMainFillInformationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        
        perform(with: segue, completion: nil)
    }
    
    func routeToTicketFillInformation(originLocation: TicketLocation, destLocation: TicketLocation, streamType: BuslineStreamType) {
        let model = ChooseBusStationParam(originCode: originLocation.code, destinationCode: destLocation.code)
        let router = ticketFillInformationBuildable.build(withListener: interactor, viewType: .ticketRoute, streamType: streamType, busStationParam: model, ticketRoundTripType: .startTicket)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToHistory() {
        let route = ticketHistoryBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: route, transitionType: .push , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToDepartTicket(ticketHistoryType: TicketHistoryType?) {
        let route = ticketHistoryDetailBuildable.build(withListener: interactor, ticketHistoryType: ticketHistoryType)
        let segue = RibsRouting(use: route, transitionType: .presentNavigation , needRemoveCurrent: true)
        perform(with: segue, completion: nil)
    }
    
    func routeToFillInformation() {
        let router = ticketUserInfomationBuildable.build(withListener: interactor)
        let segue = RibsRouting(use: router,
                                transitionType: .push,
                                needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
    
    func routeToChooseDate(dateSelected: Date?, ticketType: TicketRoundTripType) {
        let router = ticketCalendarBuildable.build(withListener: interactor, dateSelected: dateSelected, ticketType: ticketType)
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
        
    func detactCurrentChild() {
        guard let currentRouting = currentRouting else {
            return
        }
        detachChild(currentRouting)
        mViewController.dismiss(viewController: currentRouting.viewControllable, completion: nil)
    }

    private func attach(route: ViewableRouting, using transition: TransitonType) {
        defer { self.currentRouting = route }
        self.attachChild(route)
        self.mViewController.present(viewController: route.viewControllable, transitionType: transition, completion: nil)
    }
    
    func moveToDetailRoute(_ info: DetailRouteInfo) {
        let router = ticketDetailRouteBuildable.build(withListener: interactor, item: info)
        let segue = RibsRouting(use: router, transitionType: .push, needRemoveCurrent: false)
        perform(with: segue, completion: nil)
    }
}

// MARK: Class's private methods
private extension TicketDestinationRouter {
}
