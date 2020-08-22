//  File name   : BuyTicketPaymentComponent+SwitchPayment.swift
//
//  Author      : vato.
//  Created date: 10/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BuyTicketPayment to provide for the SwitchPayment scope.
// todo: Update BuyTicketPaymentDependency protocol to inherit this protocol.
protocol BuyTicketPaymentDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of BuyTicketPayment to provide dependencies
    // for the SwitchPayment scope.
}

extension BuyTicketPaymentComponent: SwitchPaymentDependency {
    // todo: Implement properties to provide for SwitchPayment scope.
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var mProfileStream: ProfileStream {
        return dependency.mutableProfile
    }

    
}
