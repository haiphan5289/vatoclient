//  File name   : UpdatePlaceRoutingComponent+LocationPicker.swift
//
//  Author      : MacbookPro
//  Created date: 12/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of UpdatePlaceRouting to provide for the LocationPicker scope.
// todo: Update UpdatePlaceRoutingDependency protocol to inherit this protocol.
protocol UpdatePlaceRoutingDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of UpdatePlaceRouting to provide dependencies
    // for the LocationPicker scope.
}

extension UpdatePlaceRoutingComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return self.authenticated
    }
    
    // todo: Implement properties to provide for LocationPicker scope.
}
