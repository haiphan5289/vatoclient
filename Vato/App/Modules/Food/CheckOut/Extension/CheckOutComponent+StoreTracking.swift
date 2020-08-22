//  File name   : CheckOutComponentComponent+StoreTracking.swift
//
//  Author      : khoi tran
//  Created date: 12/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOutComponent to provide for the StoreTracking scope.
// todo: Update CheckOutComponentDependency protocol to inherit this protocol.
protocol CheckOutDependencyStoreTracking: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOutComponent to provide dependencies
    // for the StoreTracking scope.
}

extension CheckOutComponent: StoreTrackingDependency {
    var trackingProfile: ProfileStream {
        return dependency.profile
    }
    
    var profile: ProfileStream {
        return dependency.profile
    }
    
    // todo: Implement properties to provide for StoreTracking scope.
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    
    var storeStream: MutableStoreStream? {
        return dependency.mutableStoreStream
    }
}
