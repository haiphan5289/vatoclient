//  File name   : TicketDestinationComponent+TicketCalendar.swift
//
//  Author      : vato.
//  Created date: 10/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketCalendar scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketCalendar: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketCalendar scope.
}

extension TicketDestinationComponent: TicketCalendarDependency {

    // todo: Implement properties to provide for TicketCalendar scope.
}
