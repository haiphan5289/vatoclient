//  File name   : PromotionComponent+PromotionSearch.swift
//
//  Author      : Dung Vu
//  Created date: 10/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of Promotion to provide for the PromotionSearch scope.
// todo: Update PromotionDependency protocol to inherit this protocol.
protocol PromotionDependencyPromotionSearch: Dependency {
    // todo: Declare dependencies needed from the parent scope of Promotion to provide dependencies
    // for the PromotionSearch scope.
}

extension PromotionComponent: PromotionSearchDependency {
    var promotionSearchStream: PromotionSearchStream {
        return self.promotionStream
    }
    
    var promotionSearchVC: PromotionSearchViewControllable {
        return promotionVC
    }
    

    // todo: Implement properties to provide for PromotionSearch scope.
}
