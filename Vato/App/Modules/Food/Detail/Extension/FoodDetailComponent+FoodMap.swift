//  File name   : FoodDetailComponent+FoodMap.swift
//
//  Author      : Dung Vu
//  Created date: 10/31/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodDetail to provide for the FoodMap scope.
// todo: Update FoodDetailDependency protocol to inherit this protocol.
protocol FoodDetailDependencyFoodMap: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodDetail to provide dependencies
    // for the FoodMap scope.
}

extension FoodDetailComponent: FoodMapDependency {

    // todo: Implement properties to provide for FoodMap scope.
    
}


extension FoodDetailComponent: ProductMenuDependency {
    
}


extension FoodDetailComponent: CheckOutDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
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
    
    var profile: ProfileStream {
        return dependency.foodDetailProfile
    }
    
    
}

