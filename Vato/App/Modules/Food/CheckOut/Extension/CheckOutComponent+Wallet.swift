//  File name   : CheckOutComponent+Wallet.swift
//
//  Author      : Dung Vu
//  Created date: 8/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the Wallet scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyWallet: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the Wallet scope.
}

extension CheckOutComponent: WalletDependency {
    var profileStream: ProfileStream {
        return dependency.profile
    }
    // todo: Implement properties to provide for Wallet scope.
}
