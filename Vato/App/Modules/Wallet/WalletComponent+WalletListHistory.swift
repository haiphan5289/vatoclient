//  File name   : WalletComponent+WalletListHistory.swift
//
//  Author      : Dung Vu
//  Created date: 12/6/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Wallet to provide for the WalletListHistory scope.
// todo: Update WalletDependency protocol to inherit this protocol.
protocol WalletDependencyWalletListHistory: Dependency {
    // todo: Declare dependencies needed from the parent scope of Wallet to provide dependencies
    // for the WalletListHistory scope.
}

extension WalletComponent: WalletListHistoryDependency {

    // todo: Implement properties to provide for WalletListHistory scope.
}
