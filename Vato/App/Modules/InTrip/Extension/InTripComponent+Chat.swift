//  File name   : InTripComponent+Chat.swift
//
//  Author      : Dung Vu
//  Created date: 3/11/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of InTrip to provide for the Chat scope.
// todo: Update InTripDependency protocol to inherit this protocol.
protocol InTripDependencyChat: Dependency {
    // todo: Declare dependencies needed from the parent scope of InTrip to provide dependencies
    // for the Chat scope.
}

extension InTripComponent: ChatDependency {
    var profile: ProfileStream {
        return dependency.profile
    }
    
    var chatStream: ChatStream {
        return mutableChatStream
    }

}
