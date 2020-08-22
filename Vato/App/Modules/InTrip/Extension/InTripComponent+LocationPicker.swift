//  File name   : InTripComponent+LocationPicker.swift
//
//  Author      : Dung Vu
//  Created date: 4/8/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of InTrip to provide for the LocationPicker scope.
// todo: Update InTripDependency protocol to inherit this protocol.
protocol InTripDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of InTrip to provide dependencies
    // for the LocationPicker scope.
}

extension InTripComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    // todo: Implement properties to provide for LocationPicker scope.
}
