//  File name   : VatoTabbarComponent+MainDelivery.swift
//
//  Author      : Dung Vu
//  Created date: 9/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the MainDelivery scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyMainDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the MainDelivery scope.
}

extension VatoTabbarComponent: MainDeliveryDependency {
    var bookingPoints: BookingStream {
        return mutableBookingStream
    }
    // todo: Implement properties to provide for MainDelivery scope.
}
