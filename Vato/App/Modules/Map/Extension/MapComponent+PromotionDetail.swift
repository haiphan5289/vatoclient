//  File name   : MapComponent+PromotionDetail.swift
//
//  Author      : Vato
//  Created date: 10/30/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the PromotionDetail scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyPromotionDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the PromotionDetail scope.
}

extension MapComponent: PromotionDetailDependency {

    // todo: Implement properties to provide for PromotionDetail scope.
}
