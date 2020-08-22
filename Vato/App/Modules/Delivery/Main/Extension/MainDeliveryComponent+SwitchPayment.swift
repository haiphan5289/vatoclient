//  File name   : MainDeliveryComponent+SwitchPayment.swift
//
//  Author      : Dung Vu
//  Created date: 8/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the SwitchPayment scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the SwitchPayment scope.
}

extension MainDeliveryComponent: SwitchPaymentDependency {
    
    
    var mutablePaymentStream: MutablePaymentStream {
        return self.dependency.mutablePaymentStream
    }
    // todo: Implement properties to provide for SwitchPayment scope.
    var mProfileStream: ProfileStream {
        return self.dependency.mutableProfile
    }

}
