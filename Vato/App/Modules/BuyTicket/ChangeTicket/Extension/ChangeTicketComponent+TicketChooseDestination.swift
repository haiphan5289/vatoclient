//  File name   : ChangeTicketComponent+TicketChooseDestination.swift
//
//  Author      : vato.
//  Created date: 11/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ChangeTicket to provide for the TicketChooseDestination scope.
// todo: Update ChangeTicketDependency protocol to inherit this protocol.
protocol ChangeTicketDependencyTicketChooseDestination: Dependency {
    // todo: Declare dependencies needed from the parent scope of ChangeTicket to provide dependencies
    // for the TicketChooseDestination scope.
}

extension ChangeTicketComponent: TicketChooseDestinationDependency {

    // todo: Implement properties to provide for TicketChooseDestination scope.
}
