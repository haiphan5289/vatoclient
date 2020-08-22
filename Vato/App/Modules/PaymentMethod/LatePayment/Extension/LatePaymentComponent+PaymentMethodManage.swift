//  File name   : LatePaymentComponent+PaymentMethodManage.swift
//
//  Author      : Futa Corp
//  Created date: 3/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of LatePayment to provide for the PaymentMethodManage scope.
// todo: Update LatePaymentDependency protocol to inherit this protocol.
protocol LatePaymentDependencyPaymentMethodManage: Dependency {
    var mutablePaymentStream: MutablePaymentStream { get }
}

extension LatePaymentComponent: PaymentMethodManageDependency {
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
