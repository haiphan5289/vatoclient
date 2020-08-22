//  File name   : MapComponent+PickLocation.swift
//
//  Author      : tony
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the PickLocation scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyPickLocation: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the PickLocation scope.
}

extension MapComponent: PickLocationDependency {
    var pickLocationVC: PickLocationViewControllable {
        return mapVC
    }

    // todo: Implement properties to provide for PickLocation scope.
}
