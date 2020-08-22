//  File name   : TicketHistoryDetailComponent+TicketDetailRoute.swift
//
//  Author      : Dung Vu
//  Created date: 5/29/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistoryDetail to provide for the TicketDetailRoute scope.
// todo: Update TicketHistoryDetailDependency protocol to inherit this protocol.
protocol TicketHistoryDetailDependencyTicketDetailRoute: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistoryDetail to provide dependencies
    // for the TicketDetailRoute scope.
}

extension TicketHistoryDetailComponent: TicketDetailRouteDependency {

    // todo: Implement properties to provide for TicketDetailRoute scope.
}
