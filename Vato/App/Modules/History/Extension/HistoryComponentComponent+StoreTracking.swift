//  File name   : HistoryComponentComponent+StoreTracking.swift
//
//  Author      : khoi tran
//  Created date: 1/8/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of HistoryComponent to provide for the StoreTracking scope.
// todo: Update HistoryComponentDependency protocol to inherit this protocol.
protocol HistoryComponentDependencyStoreTracking: Dependency {
    // todo: Declare dependencies needed from the parent scope of HistoryComponent to provide dependencies
    // for the StoreTracking scope.
}

extension HistoryComponent: StoreTrackingDependency {
    var trackingProfile: ProfileStream {
        return dependency.profile
    }
    
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    
    var storeStream: MutableStoreStream? {
        return nil
    }
}
