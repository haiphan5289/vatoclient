//  File name   : ShoppingMainComponent+SwitchPayment.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the SwitchPayment scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the SwitchPayment scope.
}

extension ShoppingMainComponent: SwitchPaymentDependency {
    var mProfileStream: ProfileStream {
        return dependency.mutableProfile
    }
    

    // todo: Implement properties to provide for SwitchPayment scope.
}
