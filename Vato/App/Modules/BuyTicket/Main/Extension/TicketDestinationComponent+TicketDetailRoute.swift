//  File name   : TicketDestinationComponent+TicketDetailRoute.swift
//
//  Author      : an.nguyen
//  Created date: 7/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketDetailRoute scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketDetailRoute: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketDetailRoute scope.
}

extension TicketDestinationComponent: TicketDetailRouteDependency {

    // todo: Implement properties to provide for TicketDetailRoute scope.
}
