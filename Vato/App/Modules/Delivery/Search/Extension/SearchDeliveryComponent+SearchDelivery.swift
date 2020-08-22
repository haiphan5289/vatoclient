//  File name   : MainDeliveryComponent+SearchDelivery.swift
//
//  Author      : Dung Vu
//  Created date: 8/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

extension SearchDeliveryComponent: PinAddressDependency {
    // todo: Implement properties to provide for SearchDelivery scope.
    
    var authenticatedStream: AuthenticatedStream {
        return self.dependency.authenticatedStream
    }
}
