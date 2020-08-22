//  File name   : TicketFillInformationComponent+SeatPosition.swift
//
//  Author      : khoi tran
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketFillInformation to provide for the SeatPosition scope.
// todo: Update TicketFillInformationDependency protocol to inherit this protocol.
protocol TicketFillInformationDependencySeatPosition: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketFillInformation to provide dependencies
    // for the SeatPosition scope.
}

extension TicketFillInformationComponent: SeatPositionDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authStream
    }
    

    // todo: Implement properties to provide for SeatPosition scope.
}
