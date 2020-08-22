//  File name   : VatoTaxiComponent+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTaxi to provide for the InTrip scope.
// todo: Update VatoTaxiDependency protocol to inherit this protocol.
protocol VatoTaxiDependencyInTrip: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTaxi to provide dependencies
    // for the InTrip scope.
}

extension VatoTaxiComponent: InTripDependency {
    var profile: ProfileStream {
        return dependency.profileStream
    }
    
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBooking
    }

    // todo: Implement properties to provide for InTrip scope.
}
