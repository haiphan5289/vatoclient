//  File name   : MapComponent+CarContract.swift
//
//  Author      : an.nguyen
//  Created date: 8/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the CarContract scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyCarContract: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the CarContract scope.
}

extension MapComponent: CarContractDependency {

    // todo: Implement properties to provide for CarContract scope.
}
