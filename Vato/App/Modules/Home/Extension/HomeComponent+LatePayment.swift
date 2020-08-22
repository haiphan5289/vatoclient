//  File name   : HomeComponent+LatePayment.swift
//
//  Author      : Futa Corp
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Home to provide for the LatePayment scope.
// todo: Update HomeDependency protocol to inherit this protocol.
protocol HomeDependencyLatePayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of Home to provide dependencies
    // for the LatePayment scope.
}

extension HomeComponent: LatePaymentDependency {
    var payment: PaymentStream {
        return mutablePaymentStream
    }
}
