//  File name   : AddDestinationConfirmComponent+ChangeDestinationConfirm.swift
//
//  Author      : Dung Vu
//  Created date: 4/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of AddDestinationConfirm to provide for the ChangeDestinationConfirm scope.
// todo: Update AddDestinationConfirmDependency protocol to inherit this protocol.
protocol AddDestinationConfirmDependencyChangeDestinationConfirm: Dependency {
    // todo: Declare dependencies needed from the parent scope of AddDestinationConfirm to provide dependencies
    // for the ChangeDestinationConfirm scope.
}

extension AddDestinationConfirmComponent: ChangeDestinationConfirmDependency {

    // todo: Implement properties to provide for ChangeDestinationConfirm scope.
}
