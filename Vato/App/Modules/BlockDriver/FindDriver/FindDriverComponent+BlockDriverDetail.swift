//  File name   : FindDriverComponent+BlockDriverDetail.swift
//
//  Author      : admin
//  Created date: 6/25/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FindDriver to provide for the BlockDriverDetail scope.
// todo: Update FindDriverDependency protocol to inherit this protocol.
protocol FindDriverDependencyBlockDriverDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of FindDriver to provide dependencies
    // for the BlockDriverDetail scope.
}

extension FindDriverComponent: BlockDriverDetailDependency {

    // todo: Implement properties to provide for BlockDriverDetail scope.
}
