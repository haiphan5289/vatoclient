//  File name   : ChangeTicketComponent+TicketCalendar.swift
//
//  Author      : vato.
//  Created date: 11/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ChangeTicket to provide for the TicketCalendar scope.
// todo: Update ChangeTicketDependency protocol to inherit this protocol.
protocol ChangeTicketDependencyTicketCalendar: Dependency {
    // todo: Declare dependencies needed from the parent scope of ChangeTicket to provide dependencies
    // for the TicketCalendar scope.
}

extension ChangeTicketComponent: TicketCalendarDependency {

    // todo: Implement properties to provide for TicketCalendar scope.
}
