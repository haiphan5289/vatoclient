//  File name   : SeatPositionComponent+BuyTicketPayment.swift
//
//  Author      : vato.
//  Created date: 10/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of SeatPosition to provide for the BuyTicketPayment scope.
// todo: Update SeatPositionDependency protocol to inherit this protocol.
protocol SeatPositionDependencyBuyTicketPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of SeatPosition to provide dependencies
    // for the BuyTicketPayment scope.
}

extension SeatPositionComponent: BuyTicketPaymentDependency {

    // todo: Implement properties to provide for BuyTicketPayment scope.
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
