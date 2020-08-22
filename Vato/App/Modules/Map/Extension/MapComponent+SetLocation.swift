//  File name   : MapComponent+SetLocation.swift
//
//  Author      : Dung Vu
//  Created date: 6/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the SetLocation scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencySetLocation: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the SetLocation scope.
}

extension MapComponent: SetLocationDependency {
    var mutableBookingStream: MutableBookingStream {
        return self.mutableBooking
    }
    // todo: Implement properties to provide for SetLocation scope.
}
