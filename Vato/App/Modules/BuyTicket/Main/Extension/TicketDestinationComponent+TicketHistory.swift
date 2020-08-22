//  File name   : TicketDestinationComponent+TicketHistory.swift
//
//  Author      : Dung Vu
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketHistory scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketHistory scope.
}

extension TicketDestinationComponent: TicketHistoryDependency {
    var authStream: AuthenticatedStream {
        return dependency.authStream
    }

//    var profileStream: ProfileStream {
//        return dependency.mutableProfile
//    }
    // todo: Implement properties to provide for TicketHistory scope.
}
