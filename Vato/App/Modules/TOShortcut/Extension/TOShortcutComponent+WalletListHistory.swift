//  File name   : TOShortcutComponent+WalletListHistory.swift
//
//  Author      : khoi tran
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the WalletListHistory scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyWalletListHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the WalletListHistory scope.
}

extension TOShortcutComponent: WalletListHistoryDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    

    // todo: Implement properties to provide for WalletListHistory scope.
}
