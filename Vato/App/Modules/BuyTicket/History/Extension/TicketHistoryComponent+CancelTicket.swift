//  File name   : TicketHistoryComponent+CancelTicket.swift
//
//  Author      : vato.
//  Created date: 10/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistory to provide for the CancelTicket scope.
// todo: Update TicketHistoryDependency protocol to inherit this protocol.
protocol TicketHistoryDependencyCancelTicket: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistory to provide dependencies
    // for the CancelTicket scope.
}

extension TicketHistoryComponent: CancelTicketDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authStream
    }
    // todo: Implement properties to provide for CancelTicket scope.
}
