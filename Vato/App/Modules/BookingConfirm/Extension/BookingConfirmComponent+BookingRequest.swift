//  File name   : BookingConfirmComponent+BookingRequest.swift
//
//  Author      : Dung Vu
//  Created date: 1/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the BookingRequest scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyBookingRequest: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the BookingRequest scope.
}

extension BookingConfirmComponent: BookingRequestDependency {
//    var location: LocationStream {
//        return self.dependency.location
//    }
    
    var currentModelBook: BookingConfirmInformation {
        return self.confirmStream.model
    }
    
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
}
