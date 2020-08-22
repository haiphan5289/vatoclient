//  File name   : BookingConfirmComponent+SwitchPayment.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the SwitchPayment scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the SwitchPayment scope.
}

extension BookingConfirmComponent: SwitchPaymentDependency {
    var mutablePaymentStream: MutablePaymentStream {
        return self.dependency.mutablePaymentStream
    }
    
    var mProfileStream: ProfileStream {
        return dependency.profileStream
    }

}
