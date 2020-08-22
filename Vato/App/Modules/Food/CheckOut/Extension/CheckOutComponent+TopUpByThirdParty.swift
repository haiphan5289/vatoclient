//  File name   : CheckOutComponent+TopUpByThirdParty.swift
//
//  Author      : Dung Vu
//  Created date: 4/23/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the TopUpByThirdParty scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyTopUpByThirdParty: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the TopUpByThirdParty scope.
}

extension CheckOutComponent: TopUpByThirdPartyDependency {

    // todo: Implement properties to provide for TopUpByThirdParty scope.
}
