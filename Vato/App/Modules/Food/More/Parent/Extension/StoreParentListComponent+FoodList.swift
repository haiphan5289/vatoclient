//  File name   : StoreParentListComponent+FoodList.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of StoreParentList to provide for the FoodList scope.
// todo: Update StoreParentListDependency protocol to inherit this protocol.
protocol StoreParentListDependencyFoodList: Dependency {
    // todo: Declare dependencies needed from the parent scope of StoreParentList to provide dependencies
    // for the FoodList scope.
}

extension StoreParentListComponent: FoodListDependency {

    // todo: Implement properties to provide for FoodList scope.
}
