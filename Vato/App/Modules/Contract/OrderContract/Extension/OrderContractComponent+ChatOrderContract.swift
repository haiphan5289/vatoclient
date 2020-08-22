//  File name   : OrderContractComponent+ChatOrderContract.swift
//
//  Author      : Phan Hai
//  Created date: 21/08/2020
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of OrderContract to provide for the ChatOrderContract scope.
// todo: Update OrderContractDependency protocol to inherit this protocol.
protocol OrderContractDependencyChatOrderContract: Dependency {
    // todo: Declare dependencies needed from the parent scope of OrderContract to provide dependencies
    // for the ChatOrderContract scope.
}

extension OrderContractComponent: ChatOrderContractDependency {

    // todo: Implement properties to provide for ChatOrderContract scope.
}
