//  File name   : CheckOutComponent+ProductMenu.swift
//
//  Author      : khoi tran
//  Created date: 4/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the ProductMenu scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyProductMenu: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the ProductMenu scope.
}

extension CheckOutComponent: ProductMenuDependency {

    // todo: Implement properties to provide for ProductMenu scope.
}
