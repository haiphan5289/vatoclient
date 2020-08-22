//  File name   : ShoppingMainComponent+BookingRequest.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the BookingRequest scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyBookingRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the BookingRequest scope.
}

extension ShoppingMainComponent: BookingRequestDependency {

    // todo: Implement properties to provide for BookingRequest scope.
}
