//  File name   : ChangeTicketComponent+SeatPosition.swift
//
//  Author      : vato.
//  Created date: 11/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ChangeTicket to provide for the SeatPosition scope.
// todo: Update ChangeTicketDependency protocol to inherit this protocol.
protocol ChangeTicketDependencySeatPosition: Dependency {
    // todo: Declare dependencies needed from the parent scope of ChangeTicket to provide dependencies
    // for the SeatPosition scope.
}

extension ChangeTicketComponent: SeatPositionDependency {
    var authenticatedStream: AuthenticatedStream {
        return authStream
    }
    
    

    // todo: Implement properties to provide for SeatPosition scope.
}
