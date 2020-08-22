//  File name   : BookingConfirmComponent+ConfirmDetail.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BookingConfirm to provide for the ConfirmDetail scope.
// todo: Update BookingConfirmDependency protocol to inherit this protocol.
protocol BookingConfirmDependencyConfirmDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of BookingConfirm to provide dependencies
    // for the ConfirmDetail scope.
}

extension BookingConfirmComponent: ConfirmDetailDependency {
//    var mPromotionStream: PromotionStream {
//        return self.promotionStream
//    }
//
//    var mPriceUpdate: PriceStream {
//        return self.priceUpdate
//    }
//
//    var mTransportStream: TransportStream {
//        return self.transportStream
//    }

    // todo: Implement properties to provide for ConfirmDetail scope.
}
