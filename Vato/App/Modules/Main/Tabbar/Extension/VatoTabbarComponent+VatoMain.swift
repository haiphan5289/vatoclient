//  File name   : VatoTabbarComponent+VatoMain.swift
//
//  Author      : Dung Vu
//  Created date: 8/26/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the VatoMain scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyVatoMain: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the VatoMain scope.
}

extension VatoTabbarComponent: VatoMainDependency {
    
    // todo: Implement properties to provide for VatoMain scope.
}
