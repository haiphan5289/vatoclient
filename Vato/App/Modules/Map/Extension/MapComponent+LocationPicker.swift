//  File name   : MapComponent+LocationPicker.swift
//
//  Author      : Dung Vu
//  Created date: 11/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the LocationPicker scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the LocationPicker scope.
}

extension MapComponent: LocationPickerDependency {

    // todo: Implement properties to provide for LocationPicker scope.
}
