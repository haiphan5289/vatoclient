//  File name   : WalletComponent+TopUpByThirdParty.swift
//
//  Author      : Dung Vu
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Wallet to provide for the TopUpByThirdParty scope.
// todo: Update WalletDependency protocol to inherit this protocol.
protocol WalletDependencyTopUpByThirdParty: Dependency {
    // todo: Declare dependencies needed from the parent scope of Wallet to provide dependencies
    // for the TopUpByThirdParty scope.
}

extension WalletComponent: TopUpByThirdPartyDependency {

    // todo: Implement properties to provide for TopUpByThirdParty scope.
}
