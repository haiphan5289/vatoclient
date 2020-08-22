//  File name   : HistoryComponent+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 3/19/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of History to provide for the InTrip scope.
// todo: Update HistoryDependency protocol to inherit this protocol.
protocol HistoryDependencyInTrip: Dependency {
    // todo: Declare dependencies needed from the parent scope of History to provide dependencies
    // for the InTrip scope.
}

extension HistoryComponent: InTripDependency {
    var profile: ProfileStream {
        return dependency.profile
    }
    
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBookingStream
    }
    // todo: Implement properties to provide for InTrip scope.
}
