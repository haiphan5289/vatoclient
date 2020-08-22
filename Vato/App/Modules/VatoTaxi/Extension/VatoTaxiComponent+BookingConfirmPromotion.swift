//  File name   : VatoTaxiComponent+VatoTaxiPromotion.swift
//
//  Author      : Dung Vu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTaxi to provide for the VatoTaxiPromotion scope.
// todo: Update VatoTaxiDependency protocol to inherit this protocol.

extension VatoTaxiComponent: BookingConfirmPromotionDependency {
    var priceStream: PriceStream {
        return self.priceUpdate
    }

    var authenticatedStream: AuthenticatedStream {
        return self.dependency.authenticated
    }
}
