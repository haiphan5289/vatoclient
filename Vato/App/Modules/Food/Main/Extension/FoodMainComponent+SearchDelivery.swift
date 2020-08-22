//  File name   : FoodMainComponent+SearchDelivery.swift
//
//  Author      : Dung Vu
//  Created date: 11/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the SearchDelivery scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencySearchDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the SearchDelivery scope.
}

extension FoodMainComponent: SearchDeliveryDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    // todo: Implement properties to provide for SearchDelivery scope.
}
