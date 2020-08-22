//  File name   : FoodSearchComponent+FoodDetail.swift
//
//  Author      : Dung Vu
//  Created date: 11/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodSearch to provide for the FoodDetail scope.
// todo: Update FoodSearchDependency protocol to inherit this protocol.
protocol FoodSearchDependencyFoodDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodSearch to provide dependencies
    // for the FoodDetail scope.
}

extension FoodSearchComponent: FoodDetailDependency {
    var foodDetailProfile: ProfileStream {
        return dependency.mProfileStream
    }
    
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    
    var mProfileStream: ProfileStream {
        return dependency.mProfileStream
    }
    // todo: Implement properties to provide for FoodDetail scope.
    
    var mutableStoreStream: MutableStoreStream {
        return dependency.mutableStoreStream
    }
    
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
}
