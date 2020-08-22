//  File name   : VatoMainComponent+LatePayment.swift
//
//  Author      : vato.
//  Created date: 11/7/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoMain to provide for the LatePayment scope.
// todo: Update VatoMainDependency protocol to inherit this protocol.
protocol VatoMainDependencyLatePayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoMain to provide dependencies
    // for the LatePayment scope.
}

extension VatoMainComponent: LatePaymentDependency {

    // todo: Implement properties to provide for LatePayment scope.
    
    var authenticated: AuthenticatedStream {
        return self.dependency.mutableAuthenticated
    }
    
    var profileStream: ProfileStream {
        return self.dependency.mutableProfile
    }
    
    var payment: PaymentStream {
        return self.dependency.mutablePaymentStream
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return self.dependency.mutablePaymentStream
    }
    
    var firebaseDatabase: DatabaseReference {
        return self.dependency.firebaseDatabase
    }
}

extension VatoMainComponent: SetLocationDependency {
    var authenticatedStream: AuthenticatedStream {
        return self.dependency.mutableAuthenticated
    }
    
    var mutableBookingStream: MutableBookingStream {
        return self.dependency.mutableBookingStream
    }
    
    
}
