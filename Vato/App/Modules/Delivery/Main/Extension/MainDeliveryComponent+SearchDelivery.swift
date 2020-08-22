//  File name   : MainDeliveryComponent+SearchDelivery.swift
//
//  Author      : Dung Vu
//  Created date: 8/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the SearchDelivery scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencySearchDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the SearchDelivery scope.
}

extension MainDeliveryComponent: LocationPickerDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    // todo: Implement properties to provide for SearchDelivery scope.
}
