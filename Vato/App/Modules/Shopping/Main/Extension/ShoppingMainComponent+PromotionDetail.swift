//  File name   : ShoppingMainComponent+PromotionDetail.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the PromotionDetail scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyPromotionDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the PromotionDetail scope.
}

extension ShoppingMainComponent: PromotionDetailDependency {

    // todo: Implement properties to provide for PromotionDetail scope.
}
