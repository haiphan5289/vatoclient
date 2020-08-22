//  File name   : CheckOutComponent+StoreDetailPrice.swift
//
//  Author      : khoi tran
//  Created date: 12/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the StoreDetailPrice scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyStoreDetailPrice: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the StoreDetailPrice scope.
}

extension CheckOutComponent: StoreDetailPriceDependency {
    var mutableStoreStream: MutableStoreStream {
        return dependency.mutableStoreStream
    }
    

    // todo: Implement properties to provide for StoreDetailPrice scope.

}
