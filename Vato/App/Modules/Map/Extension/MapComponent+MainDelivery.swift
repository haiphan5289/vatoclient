//  File name   : MapComponent+MainDelivery.swift
//
//  Author      : Dung Vu
//  Created date: 8/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the MainDelivery scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyMainDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the MainDelivery scope.
}

extension MapComponent: MainDeliveryDependency {

    // todo: Implement properties to provide for MainDelivery scope.
}
