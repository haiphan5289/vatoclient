//  File name   : FoodMainComponent+StoreTracking.swift
//
//  Author      : Dung Vu
//  Created date: 3/30/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the StoreTracking scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyStoreTracking: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the StoreTracking scope.
}

extension FoodMainComponent: StoreTrackingDependency {
    var trackingProfile: ProfileStream {
        return dependency.mProfileStream
    }
    
    var storeStream: MutableStoreStream? {
        return mutableStoreStream
    }
    
    var profile: ProfileStream {
        return dependency.mProfileStream
    }
    

    // todo: Implement properties to provide for StoreTracking scope.
}
