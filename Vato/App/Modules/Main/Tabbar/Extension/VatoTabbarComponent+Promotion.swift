//  File name   : VatoTabbarComponent+Promotion.swift
//
//  Author      : Dung Vu
//  Created date: 8/30/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of VatoTabbar to provide for the Promotion scope.
// todo: Update VatoTabbarDependency protocol to inherit this protocol.
protocol VatoTabbarDependencyPromotion: Dependency {
    // todo: Declare dependencies needed from the parent scope of VatoTabbar to provide dependencies
    // for the Promotion scope.
}

extension VatoTabbarComponent: PromotionDependency {
    var authenticatedStream: AuthenticatedStream {
        return self.mutableAuthenticated
    }
    
    var pTransportStream: MutableTransportStream? {
        return nil
    }
    

    // todo: Implement properties to provide for Promotion scope.
}
