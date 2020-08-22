//  File name   : TicketDestinationComponent+TicketFillInformation.swift
//
//  Author      : khoi tran
//  Created date: 4/27/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketFillInformation scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketFillInformation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketFillInformation scope.
}

extension TicketDestinationComponent: TicketFillInformationDependency {

    // todo: Implement properties to provide for TicketFillInformation scope.
}
