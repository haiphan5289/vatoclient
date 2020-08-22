//  File name   : TicketHistoryComponent+ChangeTicket.swift
//
//  Author      : vato.
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistory to provide for the ChangeTicket scope.
// todo: Update TicketHistoryDependency protocol to inherit this protocol.
protocol TicketHistoryDependencyChangeTicket: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistory to provide dependencies
    // for the ChangeTicket scope.
}

extension TicketHistoryComponent: ChangeTicketDependency {
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
