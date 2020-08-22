//  File name   : BookingConfirmComponent+ConfirmBookingChangeMethod.swift
//
//  Author      : Dung Vu
//  Created date: 10/2/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the ConfirmBookingChangeMethod scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyConfirmBookingChangeMethod: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the ConfirmBookingChangeMethod scope.
}

extension BookingConfirmComponent: ConfirmBookingChangeMethodDependency {
    // todo: Implement properties to provide for ConfirmBookingChangeMethod scope.
}
