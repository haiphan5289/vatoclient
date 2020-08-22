//  File name   : TicketHistoryDetailComponent+CancelTicket.swift
//
//  Author      : vato.
//  Created date: 10/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistoryDetail to provide for the CancelTicket scope.
// todo: Update TicketHistoryDetailDependency protocol to inherit this protocol.
protocol TicketHistoryDetailDependencyCancelTicket: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistoryDetail to provide dependencies
    // for the CancelTicket scope.
}

extension TicketHistoryDetailComponent: CancelTicketDependency {
//
    var profileStream: MutableProfileStream {
        return dependency.profileStream
    }
    // todo: Implement properties to provide for CancelTicket scope.
    var authenticatedStream: AuthenticatedStream {
        return dependency.authStream
    }
    
}
