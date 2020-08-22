//  File name   : StoreParentListComponent+FoodListCategory.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of StoreParentList to provide for the FoodListCategory scope.
// todo: Update StoreParentListDependency protocol to inherit this protocol.
protocol StoreParentListDependencyFoodListCategory: Dependency {
    // todo: Declare dependencies needed from the parent scope of StoreParentList to provide dependencies
    // for the FoodListCategory scope.
}

extension StoreParentListComponent: FoodListCategoryDependency {
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

    var mProfileStream: ProfileStream {
        return dependency.mProfileStream
    }
    // todo: Implement properties to provide for FoodListCategory scope.
}
