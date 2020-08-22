//  File name   : ProfileComponent+BlockDriver.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Profile to provide for the BlockDriver scope.
// todo: Update ProfileDependency protocol to inherit this protocol.
protocol ProfileDependencyBlockDriver: Dependency {
    // todo: Declare dependencies needed from the parent scope of Profile to provide dependencies
    // for the BlockDriver scope.
}

extension ProfileComponent: BlockDriverDependency {

    // todo: Implement properties to provide for BlockDriver scope.
}
