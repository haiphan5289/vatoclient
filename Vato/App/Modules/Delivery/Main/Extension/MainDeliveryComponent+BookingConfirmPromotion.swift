//  File name   : MainDeliveryComponent+BookingConfirmPromotion.swift
//
//  Author      : Dung Vu
//  Created date: 8/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of MainDelivery to provide for the BookingConfirmPromotion scope.
// todo: Update MainDeliveryDependency protocol to inherit this protocol.
protocol MainDeliveryDependencyBookingConfirmPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of MainDelivery to provide dependencies
    // for the BookingConfirmPromotion scope.
}

extension MainDeliveryComponent: BookingConfirmPromotionDependency {
    var authenticatedStream: AuthenticatedStream {
        return authenticated
    }
    
    var priceStream: PriceStream {
        return confirmStream
    }
    

    // todo: Implement properties to provide for BookingConfirmPromotion scope.
}
