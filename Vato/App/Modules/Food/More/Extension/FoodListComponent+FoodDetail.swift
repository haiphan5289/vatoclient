//  File name   : FoodListComponent+FoodDetail.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodList to provide for the FoodDetail scope.
// todo: Update FoodListDependency protocol to inherit this protocol.
protocol FoodListDependencyFoodDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodList to provide dependencies
    // for the FoodDetail scope.
}

extension FoodListComponent: FoodDetailDependency {
    var foodDetailProfile: ProfileStream {
        return dependency.mProfileStream
    }
    
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    var mProfileStream: ProfileStream {
        return dependency.mProfileStream
    }
    
    var mutableStoreStream: MutableStoreStream {
        return dependency.mutableStoreStream
    }
    
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    // todo: Implement properties to provide for FoodDetail scope.
}
