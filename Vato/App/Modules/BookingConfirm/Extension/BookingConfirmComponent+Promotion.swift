//  File name   : BookingConfirmComponent+Promotion.swift
//
//  Author      : Dung Vu
//  Created date: 10/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the Promotion scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the Promotion scope.
}

extension BookingConfirmComponent: PromotionDependency {
    var pTransportStream: MutableTransportStream? {
        return self.transportStream
    }
    

    // todo: Implement properties to provide for Promotion scope.
}
