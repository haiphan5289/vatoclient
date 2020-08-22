//  File name   : TicketTimeBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol TicketTimeDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authStream: AuthenticatedStream { get }
    var buyTicketStream: BuyTicketStreamImpl { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class TicketTimeComponent: Component<TicketTimeDependency> {
    /// Class's public properties.
    let TicketTimeVC: TicketTimeVC
    
    /// Class's constructor.
    init(dependency: TicketTimeDependency, TicketTimeVC: TicketTimeVC) {
        self.TicketTimeVC = TicketTimeVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketTimeBuildable: Buildable {
    func build(withListener listener: TicketTimeListener,
               ticketTimeInputModel: TicketTimeInputModel,
               streamType: BuslineStreamType,
               ticketRoundTripType: TicketRoundTripType) -> TicketTimeRouting
}

final class TicketTimeBuilder: Builder<TicketTimeDependency>, TicketTimeBuildable {
    /// Class's constructor.
    override init(dependency: TicketTimeDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketTimeBuildable's members
    func build(withListener listener: TicketTimeListener,
               ticketTimeInputModel: TicketTimeInputModel,
               streamType: BuslineStreamType, ticketRoundTripType: TicketRoundTripType) -> TicketTimeRouting {
        let vc = TicketTimeVC()
        let component = TicketTimeComponent(dependency: dependency, TicketTimeVC: vc)

        let interactor = TicketTimeInteractor(presenter: component.TicketTimeVC,
                                              authStream: component.dependency.authStream,
                                              buyTicketStream: component.dependency.buyTicketStream,
                                              ticketTimeInputModel: ticketTimeInputModel,
                                              streamType: streamType,
                                              ticketRoundTripType: ticketRoundTripType)
        interactor.listener = listener

        let ticketBusStationBuilder = TicketBusStationBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return TicketTimeRouter(interactor: interactor,
                                viewController: component.TicketTimeVC,
                                ticketBusStationBuildable: ticketBusStationBuilder)
    }
}
