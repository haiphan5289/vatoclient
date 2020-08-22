//  File name   : TicketTimeComponent+TicketBusStation.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketTime to provide for the TicketBusStation scope.
// todo: Update TicketTimeDependency protocol to inherit this protocol.
protocol TicketTimeDependencyTicketBusStation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketTime to provide dependencies
    // for the TicketBusStation scope.
}

extension TicketTimeComponent: TicketBusStationDependency {

    // todo: Implement properties to provide for TicketBusStation scope.
    var authenticatedStream: AuthenticatedStream {
        return dependency.authStream
    }
    
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
