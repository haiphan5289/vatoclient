//  File name   : MainDeliveryComponent+ConfirmDetail.swift
//
//  Author      : Dung Vu
//  Created date: 8/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the ConfirmDetail scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyConfirmDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the ConfirmDetail scope.
}

extension MainDeliveryComponent: ConfirmDetailDependency {

    // todo: Implement properties to provide for ConfirmDetail scope.
}
