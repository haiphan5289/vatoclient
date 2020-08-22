//  File name   : CheckOutComponent+EcomPromotion.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of CheckOut to provide for the EcomPromotion scope.
// todo: Update CheckOutDependency protocol to inherit this protocol.
protocol CheckOutDependencyEcomPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of CheckOut to provide dependencies
    // for the EcomPromotion scope.
}

extension CheckOutComponent: EcomPromotionDependency {

    // todo: Implement properties to provide for EcomPromotion scope.
}
