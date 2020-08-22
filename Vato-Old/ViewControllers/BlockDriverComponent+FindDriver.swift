//  File name   : BlockDriverComponent+FindDriver.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BlockDriver to provide for the FindDriver scope.
// todo: Update BlockDriverDependency protocol to inherit this protocol.
protocol BlockDriverDependencyFindDriver: Dependency {
    // todo: Declare dependencies needed from the parent scope of BlockDriver to provide dependencies
    // for the FindDriver scope.
}

extension BlockDriverComponent: FindDriverDependency {

    // todo: Implement properties to provide for FindDriver scope.
}
