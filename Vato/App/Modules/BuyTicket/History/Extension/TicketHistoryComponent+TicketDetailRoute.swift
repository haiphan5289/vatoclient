//  File name   : TicketHistoryComponent+TicketDetailRoute.swift
//
//  Author      : Dung Vu
//  Created date: 5/29/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketHistory to provide for the TicketDetailRoute scope.
// todo: Update TicketHistoryDependency protocol to inherit this protocol.
protocol TicketHistoryDependencyTicketDetailRoute: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketHistory to provide dependencies
    // for the TicketDetailRoute scope.
}

extension TicketHistoryComponent: TicketDetailRouteDependency {

    // todo: Implement properties to provide for TicketDetailRoute scope.
}
