//  File name   : VatoTabbarComponent+History.swift
//
//  Author      : vato.
//  Created date: 12/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the History scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the History scope.
}

extension VatoTabbarComponent: HistoryDependency {
    var profile: ProfileStream {
        return mutableProfile
    }
    

    // todo: Implement properties to provide for History scope.
}
