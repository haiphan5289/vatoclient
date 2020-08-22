//  File name   : FoodListCategoryComponent+FoodList.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodListCategory to provide for the FoodList scope.
// todo: Update FoodListCategoryDependency protocol to inherit this protocol.
protocol FoodListCategoryDependencyFoodList: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodListCategory to provide dependencies
    // for the FoodList scope.
}

extension FoodListCategoryComponent: FoodListDependency {
    var mutableStoreStream: MutableStoreStream {
        return dependency.mutableStoreStream
    }
    
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }

    var mProfileStream: ProfileStream {
        return dependency.mProfileStream
    }
    // todo: Implement properties to provide for FoodList scope.
}
