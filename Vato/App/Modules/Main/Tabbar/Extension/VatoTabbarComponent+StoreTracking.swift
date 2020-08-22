//  File name   : VatoTabbarComponent+StoreTracking.swift
//
//  Author      : Dung Vu
//  Created date: 2/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the StoreTracking scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyStoreTracking: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the StoreTracking scope.
}

extension VatoTabbarComponent: StoreTrackingDependency {
    var trackingProfile: ProfileStream {
        return mutableProfile
    }
    
    var storeStream: MutableStoreStream? {
        return nil
    }
    

    // todo: Implement properties to provide for StoreTracking scope.
}


extension VatoTabbarComponent: SetLocationDependency {
    
}
