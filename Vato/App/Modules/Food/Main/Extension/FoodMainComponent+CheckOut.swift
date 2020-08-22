//  File name   : FoodMainComponent+CheckOut.swift
//
//  Author      : Dung Vu
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the CheckOut scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyCheckOut: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the CheckOut scope.
}

extension FoodMainComponent: CheckOutDependency {

    // todo: Implement properties to provide for CheckOut scope.
}
