//  File name   : TicketFillInformationComponent+TicketRouteStop.swift
//
//  Author      : khoi tran
//  Created date: 4/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketFillInformation to provide for the TicketRouteStop scope.
// todo: Update TicketFillInformationDependency protocol to inherit this protocol.
protocol TicketFillInformationDependencyTicketRouteStop: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketFillInformation to provide dependencies
    // for the TicketRouteStop scope.
}

extension TicketFillInformationComponent: TicketRouteStopDependency {

    // todo: Implement properties to provide for TicketRouteStop scope.
}
