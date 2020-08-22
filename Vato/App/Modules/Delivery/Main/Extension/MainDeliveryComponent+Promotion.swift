//  File name   : MainDeliveryComponent+Promotion.swift
//
//  Author      : Dung Vu
//  Created date: 8/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the Promotion scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the Promotion scope.
}

extension MainDeliveryComponent: PromotionDependency {
    var pTransportStream: MutableTransportStream? {
        return confirmStream
    }
    

    // todo: Implement properties to provide for Promotion scope.
}
