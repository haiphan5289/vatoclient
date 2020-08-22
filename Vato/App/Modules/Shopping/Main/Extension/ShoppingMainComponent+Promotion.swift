//  File name   : ShoppingMainComponent+Promotion.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the Promotion scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the Promotion scope.
}

extension ShoppingMainComponent: PromotionDependency {
    var pTransportStream: MutableTransportStream? {
        return confirmStream

    }
    

    // todo: Implement properties to provide for Promotion scope.
}
