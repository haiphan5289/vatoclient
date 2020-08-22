//  File name   : BookingConfirmComponent+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 3/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the InTrip scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyInTrip: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the InTrip scope.
}

extension BookingConfirmComponent: InTripDependency {
    var profile: ProfileStream {
        return dependency.profileStream
    }
    // todo: Implement properties to provide for InTrip scope.
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBooking
    }
}
