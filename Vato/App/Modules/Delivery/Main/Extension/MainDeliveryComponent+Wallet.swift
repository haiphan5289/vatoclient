//  File name   : MainDeliveryComponent+Wallet.swift
//
//  Author      : Dung Vu
//  Created date: 8/6/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the Wallet scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyWallet: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the Wallet scope.
}

extension MainDeliveryComponent: WalletDependency {

    // todo: Implement properties to provide for Wallet scope.
}
