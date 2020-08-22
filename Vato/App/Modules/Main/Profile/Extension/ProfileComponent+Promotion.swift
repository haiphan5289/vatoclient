//  File name   : ProfileComponent+Promotion.swift
//
//  Author      : Dung Vu
//  Created date: 3/4/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Profile to provide for the Promotion scope.
// todo: Update ProfileDependency protocol to inherit this protocol.
protocol ProfileDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of Profile to provide dependencies
    // for the Promotion scope.
}

extension ProfileComponent: PromotionDependency {

    // todo: Implement properties to provide for Promotion scope.
    var pTransportStream: MutableTransportStream? {
        return dependency.pTransportStream
    }
    
}
