
//  File name   : TicketDestinationComponent+TicketMainFillInformation.swift
//
//  Author      : khoi tran
//  Created date: 5/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketDestination to provide for the TicketMainFillInformation scope.
// todo: Update TicketDestinationDependency protocol to inherit this protocol.
protocol TicketDestinationDependencyTicketMainFillInformation: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketDestination to provide dependencies
    // for the TicketMainFillInformation scope.
}

extension TicketDestinationComponent: TicketMainFillInformationDependency {

    // todo: Implement properties to provide for TicketMainFillInformation scope.
}
