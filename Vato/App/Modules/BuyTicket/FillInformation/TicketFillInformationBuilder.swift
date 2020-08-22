//  File name   : TicketFillInformationBuilder.swift
//
//  Author      : khoi tran
//  Created date: 4/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TicketFillInformationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var buyTicketStream: BuyTicketStreamImpl { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var authStream: AuthenticatedStream { get }

}

final class TicketFillInformationComponent: Component<TicketFillInformationDependency> {
    /// Class's public properties.
    let TicketFillInformationVC: TicketFillInformationVC
    
    /// Class's constructor.
    init(dependency: TicketFillInformationDependency, TicketFillInformationVC: TicketFillInformationVC) {
        self.TicketFillInformationVC = TicketFillInformationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketFillInformationBuildable: Buildable {
    func build(withListener listener: TicketFillInformationListener, viewType: BusStationType, streamType: BuslineStreamType, busStationParam: ChooseBusStationParam?, ticketRoundTripType: TicketRoundTripType) -> TicketFillInformationRouting
}

final class TicketFillInformationBuilder: Builder<TicketFillInformationDependency>, TicketFillInformationBuildable {
    /// Class's constructor.
    override init(dependency: TicketFillInformationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketFillInformationBuildable's members
     func build(withListener listener: TicketFillInformationListener, viewType: BusStationType, streamType: BuslineStreamType, busStationParam: ChooseBusStationParam?, ticketRoundTripType: TicketRoundTripType) -> TicketFillInformationRouting {
        let vc = TicketFillInformationVC()
        let component = TicketFillInformationComponent(dependency: dependency, TicketFillInformationVC: vc)

        let interactor = TicketFillInformationInteractor(presenter: component.TicketFillInformationVC, buyTicketStream: component.dependency.buyTicketStream, streamType: streamType, viewType: viewType, busStationParam: busStationParam, profileStream: dependency.mutableProfile, ticketRoundTripType: ticketRoundTripType)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let ticketTimeBuilder = TicketTimeBuilder(dependency: component)
        let ticketRouteStopBuilder = TicketRouteStopBuilder(dependency: component)
        let seatPositionBuilder = SeatPositionBuilder(dependency: component)
        
        return TicketFillInformationRouter(interactor: interactor, viewController: component.TicketFillInformationVC, ticketTimeBuildable: ticketTimeBuilder, ticketRouteStopBuildable: ticketRouteStopBuilder, seatPositionBuildable: seatPositionBuilder)
    }
}
