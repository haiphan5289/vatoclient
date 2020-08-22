//  File name   : ShoppingMainComponent+ShoppingFillInformation.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the ShoppingFillInformation scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyShoppingFillInformation: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the ShoppingFillInformation scope.
}

extension ShoppingMainComponent: ShoppingFillInformationDependency {

    // todo: Implement properties to provide for ShoppingFillInformation scope.
}
