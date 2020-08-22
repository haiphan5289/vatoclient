//  File name   : ShoppingMainComponent+PinAddress.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the PinAddress scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyPinAddress: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the PinAddress scope.
}

extension ShoppingMainComponent: PinAddressDependency {

    // todo: Implement properties to provide for PinAddress scope.
}
