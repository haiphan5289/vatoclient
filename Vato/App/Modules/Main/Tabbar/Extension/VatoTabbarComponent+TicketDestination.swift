//  File name   : VatoTabbarComponent+TicketDestination.swift
//
//  Author      : vato.
//  Created date: 10/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the TicketDestination scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyTicketDestination: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the TicketDestination scope.
}

extension VatoTabbarComponent: TicketDestinationDependency {
    var authStream: AuthenticatedStream {
        return authenticated
    }
    
    // todo: Implement properties to provide for TicketDestination scope.
}


