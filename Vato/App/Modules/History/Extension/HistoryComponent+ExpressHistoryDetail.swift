//  File name   : HistoryComponent+ExpressHistoryDetail.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of History to provide for the ExpressHistoryDetail scope.
// todo: Update HistoryDependency protocol to inherit this protocol.
protocol HistoryDependencyExpressHistoryDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of History to provide dependencies
    // for the ExpressHistoryDetail scope.
}

extension HistoryComponent: ExpressHistoryDetailDependency {

    // todo: Implement properties to provide for ExpressHistoryDetail scope.
}
