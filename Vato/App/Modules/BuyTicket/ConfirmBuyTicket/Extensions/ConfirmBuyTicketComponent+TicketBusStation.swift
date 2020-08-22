//  File name   : ConfirmBuyTicketComponent+TicketBusStation.swift
//
//  Author      : vato.
//  Created date: 10/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ConfirmBuyTicket to provide for the TicketBusStation scope.
// todo: Update ConfirmBuyTicketDependency protocol to inherit this protocol.
protocol ConfirmBuyTicketDependencyTicketBusStation: Dependency {
    // todo: Declare dependencies needed from the parent scope of ConfirmBuyTicket to provide dependencies
    // for the TicketBusStation scope.
}

extension ConfirmBuyTicketComponent: TicketBusStationDependency {

    // todo: Implement properties to provide for TicketBusStation scope.
}
