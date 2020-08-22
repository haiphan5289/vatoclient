//  File name   : TicketBusStationComponent+SeatPosition.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketBusStation to provide for the SeatPosition scope.
// todo: Update TicketBusStationDependency protocol to inherit this protocol.
protocol TicketBusStationDependencySeatPosition: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketBusStation to provide dependencies
    // for the SeatPosition scope.
}

extension TicketBusStationComponent: SeatPositionDependency {
    var authenticatedStream: AuthenticatedStream {
        return authStream
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
