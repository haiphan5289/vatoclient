//  File name   : TicketDestinationComponent+TicketHistoryDetail.swift
//
//  Author      : vato.
//  Created date: 10/17/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketHistoryDetail scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketHistoryDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketHistoryDetail scope.
}

extension TicketDestinationComponent: TicketHistoryDetailDependency {
    var profileStream: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    
    // todo: Implement properties to provide for TicketHistoryDetail scope.
}
