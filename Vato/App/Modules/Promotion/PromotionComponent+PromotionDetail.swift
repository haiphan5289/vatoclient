//  File name   : PromotionComponent+PromotionDetail.swift
//
//  Author      : Dung Vu
//  Created date: 10/24/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Promotion to provide for the PromotionDetail scope.
// todo: Update PromotionDependency protocol to inherit this protocol.
protocol PromotionDependencyPromotionDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of Promotion to provide dependencies
    // for the PromotionDetail scope.
}

extension PromotionComponent: PromotionDetailDependency {
}
