//  File name   : ProfileComponent+QuickSupportMain.swift
//
//  Author      : Dung Vu
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Profile to provide for the QuickSupportMain scope.
// todo: Update ProfileDependency protocol to inherit this protocol.
protocol ProfileDependencyQuickSupportMain: Dependency {
    // todo: Declare dependencies needed from the parent scope of Profile to provide dependencies
    // for the QuickSupportMain scope.
}

extension ProfileComponent: QuickSupportMainDependency {

    // todo: Implement properties to provide for QuickSupportMain scope.
}
