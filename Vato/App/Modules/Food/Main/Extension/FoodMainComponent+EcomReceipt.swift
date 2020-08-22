//  File name   : FoodMainComponent+EcomReceipt.swift
//
//  Author      : Dung Vu
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of FoodMain to provide for the EcomReceipt scope.
// todo: Update FoodMainDependency protocol to inherit this protocol.
protocol FoodMainDependencyEcomReceipt: Dependency {
    // todo: Declare dependencies needed from the parent scope of FoodMain to provide dependencies
    // for the EcomReceipt scope.
}

extension FoodMainComponent: EcomReceiptDependency {

    // todo: Implement properties to provide for EcomReceipt scope.
}
