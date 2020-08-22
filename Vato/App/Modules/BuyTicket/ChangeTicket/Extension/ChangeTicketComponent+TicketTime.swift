//  File name   : ChangeTicketComponent+TicketTime.swift
//
//  Author      : vato.
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ChangeTicket to provide for the TicketTime scope.
// todo: Update ChangeTicketDependency protocol to inherit this protocol.
protocol ChangeTicketDependencyTicketTime: Dependency {
    // todo: Declare dependencies needed from the parent scope of ChangeTicket to provide dependencies
    // for the TicketTime scope.
}

extension ChangeTicketComponent: TicketTimeDependency {
    var authStream: AuthenticatedStream {
        return dependency.authStream
    }
    
    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
    // todo: Implement properties to provide for TicketTime scope.
}
