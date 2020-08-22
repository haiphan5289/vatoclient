//  File name   : ConfirmBuyTicketComponent+TicketTime.swift
//
//  Author      : vato.
//  Created date: 10/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ConfirmBuyTicket to provide for the TicketTime scope.
// todo: Update ConfirmBuyTicketDependency protocol to inherit this protocol.
protocol ConfirmBuyTicketDependencyTicketTime: Dependency {
    // todo: Declare dependencies needed from the parent scope of ConfirmBuyTicket to provide dependencies
    // for the TicketTime scope.
}

extension ConfirmBuyTicketComponent: TicketTimeDependency {

    // todo: Implement properties to provide for TicketTime scope.
    
    var authStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
}
