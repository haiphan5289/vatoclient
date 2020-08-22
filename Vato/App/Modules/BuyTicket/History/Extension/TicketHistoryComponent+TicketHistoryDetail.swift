//  File name   : TicketHistoryComponent+TicketHistoryDetail.swift
//
//  Author      : vato.
//  Created date: 10/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistory to provide for the TicketHistoryDetail scope.
// todo: Update TicketHistoryDependency protocol to inherit this protocol.
protocol TicketHistoryDependencyTicketHistoryDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistory to provide dependencies
    // for the TicketHistoryDetail scope.
}

extension TicketHistoryComponent: TicketHistoryDetailDependency {

    // todo: Implement properties to provide for TicketHistoryDetail scope.
    var authStream: AuthenticatedStream {
        return dependency.authStream
    }
    
    var profileStream: MutableProfileStream {
        return dependency.mutableProfile
    }
}
