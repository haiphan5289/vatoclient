//  File name   : FoodMainComponent+FoodSearch.swift
//
//  Author      : Dung Vu
//  Created date: 11/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the FoodSearch scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyFoodSearch: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the FoodSearch scope.
}

extension FoodMainComponent: FoodSearchDependency {
    // todo: Implement properties to provide for FoodSearch scope.
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var mProfileStream: ProfileStream {
        return dependency.mProfileStream
    }
}
