//  File name   : RootComponent+LoggedOut.swift
//
//  Author      : Vato
//  Created date: 9/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Root to provide for the LoggedOut scope.
// todo: Update RootDependency protocol to inherit this protocol.
protocol RootDependencyLoggedOut: Dependency {
    // todo: Declare dependencies needed from the parent scope of Root to provide dependencies
    // for the LoggedOut scope.
}

extension RootComponent: LoggedOutDependency {
    // todo: Implement properties to provide for LoggedOut scope.
}
