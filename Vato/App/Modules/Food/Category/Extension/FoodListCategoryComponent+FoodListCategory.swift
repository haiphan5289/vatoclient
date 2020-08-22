//  File name   : FoodListCategoryComponent+FoodListCategory.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodListCategory to provide for the FoodListCategory scope.
// todo: Update FoodListCategoryDependency protocol to inherit this protocol.
protocol FoodListCategoryDependencyFoodListCategory: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodListCategory to provide dependencies
    // for the FoodListCategory scope.
}

extension FoodListCategoryComponent: FoodListCategoryDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    // todo: Implement properties to provide for FoodListCategory scope.
}
