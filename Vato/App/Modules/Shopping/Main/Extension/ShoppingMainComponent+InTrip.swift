//  File name   : ShoppingMainComponent+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 4/14/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the InTrip scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyInTrip: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the InTrip scope.
}

extension ShoppingMainComponent: InTripDependency {
    var profile: ProfileStream {
        return dependency.mutableProfile
    }
    
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBookingStream
    }
    

    // todo: Implement properties to provide for InTrip scope.
}
