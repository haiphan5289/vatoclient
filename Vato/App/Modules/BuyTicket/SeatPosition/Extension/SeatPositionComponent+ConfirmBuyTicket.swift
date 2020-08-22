//  File name   : SeatPositionComponent+ConfirmBuyTicket.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of SeatPosition to provide for the ConfirmBuyTicket scope.
// todo: Update SeatPositionDependency protocol to inherit this protocol.
protocol SeatPositionDependencyConfirmBuyTicket: Dependency {
    // todo: Declare dependencies needed from the parent scope of SeatPosition to provide dependencies
    // for the ConfirmBuyTicket scope.
}

extension SeatPositionComponent: ConfirmBuyTicketDependency {
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }
    
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    // todo: Implement properties to provide for ConfirmBuyTicket scope.
}
