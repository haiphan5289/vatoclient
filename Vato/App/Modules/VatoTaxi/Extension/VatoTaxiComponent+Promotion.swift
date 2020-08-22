//  File name   : VatoTaxiComponent+Promotion.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTaxi to provide for the Promotion scope.
// todo: Update VatoTaxiDependency protocol to inherit this protocol.
protocol VatoTaxiDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTaxi to provide dependencies
    // for the Promotion scope.
}

extension VatoTaxiComponent: PromotionDependency {
    var pTransportStream: MutableTransportStream? {
        return self.transportStream
    }
    

    // todo: Implement properties to provide for Promotion scope.
}
