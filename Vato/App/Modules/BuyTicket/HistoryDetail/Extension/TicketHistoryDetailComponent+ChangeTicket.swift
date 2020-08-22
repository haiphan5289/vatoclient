//  File name   : TicketHistoryDetailComponent+ChangeTicket.swift
//
//  Author      : MacbookPro
//  Created date: 11/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistoryDetail to provide for the ChangeTicket scope.
// todo: Update TicketHistoryDetailDependency protocol to inherit this protocol.
protocol TicketHistoryDetailDependencyChangeTicket: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistoryDetail to provide dependencies
    // for the ChangeTicket scope.
}

extension TicketHistoryDetailComponent: ChangeTicketDependency {
    var authStream: AuthenticatedStream {
        return authenticatedStream
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.profileStream
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
