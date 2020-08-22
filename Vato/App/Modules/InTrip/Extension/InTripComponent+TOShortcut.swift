//  File name   : InTripComponent+TOShortcut.swift
//
//  Author      : khoi tran
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of InTrip to provide for the TOShortcut scope.
// todo: Update InTripDependency protocol to inherit this protocol.
protocol InTripDependencyTOShortcut: Dependency {
    // todo: Declare dependencies needed from the parent scope of InTrip to provide dependencies
    // for the TOShortcut scope.
}

extension InTripComponent: TOShortcutDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var mutableBookingStream: MutableBookingStream {
        return dependency.mutableBookingStream
    }
    
    // todo: Implement properties to provide for TOShortcut scope.
}


