//  File name   : VatoMainComponent+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 3/13/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoMain to provide for the InTrip scope.
// todo: Update VatoMainDependency protocol to inherit this protocol.
protocol VatoMainDependencyInTrip: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoMain to provide dependencies
    // for the InTrip scope.
}

extension VatoMainComponent: InTripDependency {
    var profile: ProfileStream {
        return dependency.mutableProfile
    }
}
