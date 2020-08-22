//  File name   : FoodMainComponent+FoodListCategory.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the FoodListCategory scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyFoodListCategory: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the FoodListCategory scope.
}

extension FoodMainComponent: FoodListCategoryDependency {

    // todo: Implement properties to provide for FoodListCategory scope.
}
