//  File name   : CarContractComponent+OrderContract.swift
//
//  Author      : Phan Hai
//  Created date: 19/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CarContract to provide for the OrderContract scope.
// todo: Update CarContractDependency protocol to inherit this protocol.
protocol CarContractDependencyOrderContract: Dependency {
    // todo: Declare dependencies needed from the parent scope of CarContract to provide dependencies
    // for the OrderContract scope.
}

extension CarContractComponent: OrderContractDependency {

    // todo: Implement properties to provide for OrderContract scope.
}
