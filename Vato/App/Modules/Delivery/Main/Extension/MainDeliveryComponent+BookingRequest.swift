//  File name   : MainDeliveryComponent+BookingRequest.swift
//
//  Author      : Dung Vu
//  Created date: 8/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the BookingRequest scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyBookingRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the BookingRequest scope.
}

extension MainDeliveryComponent: BookingRequestDependency {

    // todo: Implement properties to provide for BookingRequest scope.
}
