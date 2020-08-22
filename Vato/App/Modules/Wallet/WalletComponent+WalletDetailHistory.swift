//  File name   : WalletComponent+WalletDetailHistory.swift
//
//  Author      : Dung Vu
//  Created date: 12/5/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Wallet to provide for the WalletDetailHistory scope.
// todo: Update WalletDependency protocol to inherit this protocol.
protocol WalletDependencyWalletDetailHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of Wallet to provide dependencies
    // for the WalletDetailHistory scope.
}

extension WalletComponent: WalletDetailHistoryDependency {
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
}
