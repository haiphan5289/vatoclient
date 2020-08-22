//  File name   : BookingConfirmComponent+BookingConfirmPromotion.swift
//
//  Author      : Dung Vu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the BookingConfirmPromotion scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyBookingConfirmPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the BookingConfirmPromotion scope.
}

extension BookingConfirmComponent: BookingConfirmPromotionDependency {
    var priceStream: PriceStream {
        return self.priceUpdate
    }

    var authenticatedStream: AuthenticatedStream {
        return self.dependency.authenticated
    }
}
