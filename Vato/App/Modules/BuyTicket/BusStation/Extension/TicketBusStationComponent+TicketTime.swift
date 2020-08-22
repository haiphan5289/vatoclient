//  File name   : TicketBusStationComponent+TicketTime.swift
//
//  Author      : vato.
//  Created date: 10/9/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketBusStation to provide for the TicketTime scope.
// todo: Update TicketBusStationDependency protocol to inherit this protocol.
protocol TicketBusStationDependencyTicketTime: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketBusStation to provide dependencies
    // for the TicketTime scope.
}

extension TicketBusStationComponent: TicketTimeDependency {
    var authStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }

    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    // todo: Implement properties to provide for TicketTime scope.
}
