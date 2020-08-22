//  File name   : MapComponent+Promotion.swift
//
//  Author      : Vato
//  Created date: 10/30/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Map to provide for the Promotion scope.
// todo: Update MapDependency protocol to inherit this protocol.
protocol MapDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of Map to provide dependencies
    // for the Promotion scope.
}

extension MapComponent: PromotionDependency {
    var authenticatedStream: AuthenticatedStream {
        return authenticated
    }

    var pTransportStream: MutableTransportStream? {
        return nil
    }
}
