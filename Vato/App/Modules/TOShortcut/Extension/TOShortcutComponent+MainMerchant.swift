//  File name   : TOShortcutComponent+MainMerchant.swift
//
//  Author      : khoi tran
//  Created date: 3/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TOShortcut to provide for the MainMerchant scope.
// todo: Update TOShortcutDependency protocol to inherit this protocol.
protocol TOShortcutDependencyMainMerchant: Dependency {
    // todo: Declare dependencies needed from the parent scope of TOShortcut to provide dependencies
    // for the MainMerchant scope.
}

extension TOShortcutComponent: MainMerchantDependency {
    var authenticatedStream: AuthenticatedStream {
        return authenticated
    }
    

    // todo: Implement properties to provide for MainMerchant scope.
}
