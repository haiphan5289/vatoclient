//  File name   : ConfirmBuyTicketComponent+TicketCalendar.swift
//
//  Author      : vato.
//  Created date: 10/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ConfirmBuyTicket to provide for the TicketCalendar scope.
// todo: Update ConfirmBuyTicketDependency protocol to inherit this protocol.
protocol ConfirmBuyTicketDependencyTicketCalendar: Dependency {
    // todo: Declare dependencies needed from the parent scope of ConfirmBuyTicket to provide dependencies
    // for the TicketCalendar scope.
}

extension ConfirmBuyTicketComponent: TicketCalendarDependency {

    // todo: Implement properties to provide for TicketCalendar scope.
}
