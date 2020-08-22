//  File name   : ShoppingMainComponent+BookingConfirmPromotion.swift
//
//  Author      : khoi tran
//  Created date: 4/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the BookingConfirmPromotion scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyBookingConfirmPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the BookingConfirmPromotion scope.
}

extension ShoppingMainComponent: BookingConfirmPromotionDependency {
    var priceStream: PriceStream {
        return confirmStream
    }
    

    // todo: Implement properties to provide for BookingConfirmPromotion scope.
}
