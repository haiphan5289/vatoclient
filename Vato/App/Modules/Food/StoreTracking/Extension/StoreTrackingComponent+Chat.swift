//  File name   : StoreTrackingComponent+Chat.swift
//
//  Author      : Dung Vu
//  Created date: 3/28/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of StoreTracking to provide for the Chat scope.
// todo: Update StoreTrackingDependency protocol to inherit this protocol.
protocol StoreTrackingDependencyChat: Dependency {
    // todo: Declare dependencies needed from the parent scope of StoreTracking to provide dependencies
    // for the Chat scope.
}

extension StoreTrackingComponent: ChatDependency {
    var profile: ProfileStream {
        return dependency.trackingProfile

    }
    
    var chatStream: ChatStream {
        return mutableChatStream
    }
    

    // todo: Implement properties to provide for Chat scope.
}
