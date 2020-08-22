//  File name   : BlockDriverComponent+BlockDriverDetail.swift
//
//  Author      : admin
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BlockDriver to provide for the BlockDriverDetail scope.
// todo: Update BlockDriverDependency protocol to inherit this protocol.
protocol BlockDriverDependencyBlockDriverDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of BlockDriver to provide dependencies
    // for the BlockDriverDetail scope.
}

extension BlockDriverComponent: BlockDriverDetailDependency {

    // todo: Implement properties to provide for BlockDriverDetail scope.
}
