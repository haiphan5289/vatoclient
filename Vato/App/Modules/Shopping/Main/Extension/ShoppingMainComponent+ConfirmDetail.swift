//  File name   : ShoppingMainComponent+ConfirmDetail.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the ConfirmDetail scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyConfirmDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the ConfirmDetail scope.
}

extension ShoppingMainComponent: ConfirmDetailDependency {

    // todo: Implement properties to provide for ConfirmDetail scope.
}
