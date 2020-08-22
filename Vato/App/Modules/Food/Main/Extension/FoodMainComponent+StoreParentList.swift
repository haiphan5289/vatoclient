//  File name   : FoodMainComponent+StoreParentList.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the StoreParentList scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyStoreParentList: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the StoreParentList scope.
}

extension FoodMainComponent: StoreParentListDependency {

    // todo: Implement properties to provide for StoreParentList scope.
}
