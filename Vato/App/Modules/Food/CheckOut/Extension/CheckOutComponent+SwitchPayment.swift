//  File name   : CheckOutComponent+SwitchPayment.swift
//
//  Author      : vato.
//  Created date: 12/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the SwitchPayment scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the SwitchPayment scope.
}

extension CheckOutComponent: SwitchPaymentDependency {

    // todo: Implement properties to provide for SwitchPayment scope.
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var mProfileStream: ProfileStream {
        return dependency.profile
    }
}
