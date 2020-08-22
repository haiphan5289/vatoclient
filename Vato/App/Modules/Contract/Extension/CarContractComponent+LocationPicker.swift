//  File name   : CarContractComponent+LocationPicker.swift
//
//  Author      : an.nguyen
//  Created date: 8/20/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CarContract to provide for the LocationPicker scope.
// todo: Update CarContractDependency protocol to inherit this protocol.
protocol CarContractDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of CarContract to provide dependencies
    // for the LocationPicker scope.
}

extension CarContractComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    
    // todo: Implement properties to provide for LocationPicker scope.
}
