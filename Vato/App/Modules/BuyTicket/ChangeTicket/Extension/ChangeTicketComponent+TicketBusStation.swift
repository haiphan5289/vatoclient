//  File name   : ChangeTicketComponent+TicketBusStation.swift
//
//  Author      : vato.
//  Created date: 11/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ChangeTicket to provide for the TicketBusStation scope.
// todo: Update ChangeTicketDependency protocol to inherit this protocol.
protocol ChangeTicketDependencyTicketBusStation: Dependency {
    // todo: Declare dependencies needed from the parent scope of ChangeTicket to provide dependencies
    // for the TicketBusStation scope.
}

extension ChangeTicketComponent: TicketBusStationDependency {
    // todo: Implement properties to provide for TicketBusStation scope.
}
