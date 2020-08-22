//  File name   : FoodListComponent+CheckOut.swift
//
//  Author      : Dung Vu
//  Created date: 7/7/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodList to provide for the CheckOut scope.
// todo: Update FoodListDependency protocol to inherit this protocol.
protocol FoodListDependencyCheckOut: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodList to provide dependencies
    // for the CheckOut scope.
}

extension FoodListComponent: CheckOutDependency {
    var profile: ProfileStream {
        return dependency.mProfileStream
    }
    // todo: Implement properties to provide for CheckOut scope.
}
