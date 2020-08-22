//  File name   : MainDeliveryComponent+FillInformation.swift
//
//  Author      : Dung Vu
//  Created date: 8/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the FillInformation scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyFillInformation: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the FillInformation scope.
}

extension MainDeliveryComponent: FillInformationDependency {

    // todo: Implement properties to provide for FillInformation scope.
}
