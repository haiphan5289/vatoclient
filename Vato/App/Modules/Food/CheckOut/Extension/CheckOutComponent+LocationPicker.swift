//  File name   : CheckOutComponent+LocationPicker.swift
//
//  Author      : khoi tran
//  Created date: 12/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the LocationPicker scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the LocationPicker scope.
}

extension CheckOutComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    

    // todo: Implement properties to provide for LocationPicker scope.
}
