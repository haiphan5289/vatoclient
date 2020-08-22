//  File name   : VatoTaxiComponent+SwitchPayment.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTaxi to provide for the SwitchPayment scope.
// todo: Update VatoTaxiDependency protocol to inherit this protocol.
protocol VatoTaxiDependencySwitchPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTaxi to provide dependencies
    // for the SwitchPayment scope.
}

extension VatoTaxiComponent: SwitchPaymentDependency {
    
    
    
    var mutablePaymentStream: MutablePaymentStream {
        return self.dependency.mutablePaymentStream
    }
    
    var mProfileStream: ProfileStream {
        return self.dependency.profileStream
    }
    
}
