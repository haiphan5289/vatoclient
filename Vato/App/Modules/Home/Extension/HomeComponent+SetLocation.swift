//  File name   : HomeComponent+SetLocation.swift
//
//  Author      : Dung Vu
//  Created date: 6/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Home to provide for the SetLocation scope.
// todo: Update HomeDependency protocol to inherit this protocol.
protocol HomeDependencySetLocation: Dependency {
    // todo: Declare dependencies needed from the parent scope of Home to provide dependencies
    // for the SetLocation scope.
}

extension HomeComponent: SetLocationDependency {
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBooking
    }
    

    // todo: Implement properties to provide for SetLocation scope.
}
