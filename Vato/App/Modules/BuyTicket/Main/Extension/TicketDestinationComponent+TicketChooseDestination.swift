//  File name   : TicketDestinationComponent+TicketChooseDestination.swift
//
//  Author      : vato.
//  Created date: 10/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketChooseDestination scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketChooseDestination: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketChooseDestination scope.
}

extension TicketDestinationComponent: TicketChooseDestinationDependency {

    // todo: Implement properties to provide for TicketChooseDestination scope.
    var authenticatedStream: AuthenticatedStream {
        return dependency.authStream
    }
}
