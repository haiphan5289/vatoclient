//  File name   : FoodMainComponent+FoodDetail.swift
//
//  Author      : Dung Vu
//  Created date: 10/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the FoodDetail scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyFoodDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the FoodDetail scope.
}

extension FoodMainComponent: FoodDetailDependency {
    var foodDetailProfile: ProfileStream {
        return dependency.mProfileStream
    }
    
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
}
