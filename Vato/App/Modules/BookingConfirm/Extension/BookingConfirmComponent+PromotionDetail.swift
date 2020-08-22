//  File name   : BookingConfirmComponent+PromotionDetail.swift
//
//  Author      : Dung Vu
//  Created date: 10/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the PromotionDetail scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyPromotionDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the PromotionDetail scope.
}

extension BookingConfirmComponent: PromotionDetailDependency {

    // todo: Implement properties to provide for PromotionDetail scope.
}
