//  File name   : TOShortcutComponent+History.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the History scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the History scope.
}

extension TOShortcutComponent: HistoryDependency {
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var profile: ProfileStream {
        return dependency.profile
    }
    

    // todo: Implement properties to provide for History scope.
}
