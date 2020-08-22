//  File name   : MainDeliveryComponent+PinAddress.swift
//
//  Author      : MacbookPro
//  Created date: 11/27/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the PinAddress scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyPinAddress: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the PinAddress scope.
}

extension MainDeliveryComponent: PinAddressDependency {

    // todo: Implement properties to provide for PinAddress scope.
}
