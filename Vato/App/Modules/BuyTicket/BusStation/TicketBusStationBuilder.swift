//  File name   : TicketBusStationBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

struct ChooseBusStationParam {
    var originCode: String
    var destinationCode: String
}

struct ChooseRouteStopParam {
    var routeId: Int
    var departureDate: String
    var departureTime: String
    var wayId: Int32
}

enum BusStationType {
    case ticketRoute
    case routeStop
}

// MARK: Dependency tree
protocol TicketBusStationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var buyTicketStream: BuyTicketStreamImpl { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class TicketBusStationComponent: Component<TicketBusStationDependency> {
    /// Class's public properties.
    let TicketBusStationVC: TicketBusStationVC
    
    /// Class's constructor.
    init(dependency: TicketBusStationDependency, TicketBusStationVC: TicketBusStationVC) {
        self.TicketBusStationVC = TicketBusStationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TicketBusStationBuildable: Buildable {
    func build(withListener listener: TicketBusStationListener,
               viewType: BusStationType,
               busParam: ChooseBusStationParam?,
               stopParam: ChooseRouteStopParam?,
               streamType: BuslineStreamType) -> TicketBusStationRouting
}

final class TicketBusStationBuilder: Builder<TicketBusStationDependency>, TicketBusStationBuildable {
    /// Class's constructor.
    override init(dependency: TicketBusStationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: TicketBusStationBuildable's members
    func build(withListener listener: TicketBusStationListener,
               viewType: BusStationType,
               busParam: ChooseBusStationParam?,
               stopParam: ChooseRouteStopParam?,
               streamType: BuslineStreamType) -> TicketBusStationRouting {
        
        let vc = TicketBusStationVC(viewType: viewType, busParam: busParam, stopParam: stopParam)
        let component = TicketBusStationComponent(dependency: dependency, TicketBusStationVC: vc)

        let interactor = TicketBusStationInteractor(presenter: component.TicketBusStationVC,
                                                    authStream: component.dependency.authenticatedStream,
                                                    buyTicketStream: component.dependency.buyTicketStream,
                                                    streamType: streamType)
        interactor.listener = listener

        let ticketTimeBuilder = TicketTimeBuilder(dependency: component)
        let seatPositionBuilder = SeatPositionBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return TicketBusStationRouter(interactor: interactor,
                                      viewController: component.TicketBusStationVC,
                                      ticketTimeBuildable: ticketTimeBuilder,
                                      seatPositionBuildable: seatPositionBuilder)
    }
}
