//  File name   : MainDeliveryComponent+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 4/2/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the InTrip scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyInTrip: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the InTrip scope.
}

extension MainDeliveryComponent: InTripDependency {
    var profile: ProfileStream {
        return dependency.mutableProfile
    }
    
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBookingStream
    }

    // todo: Implement properties to provide for InTrip scope.
}
