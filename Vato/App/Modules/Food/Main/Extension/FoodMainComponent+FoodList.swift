//  File name   : FoodMainComponent+FoodList.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the FoodList scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyFoodList: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the FoodList scope.
}

extension FoodMainComponent: FoodListDependency {

    // todo: Implement properties to provide for FoodList scope.
}
