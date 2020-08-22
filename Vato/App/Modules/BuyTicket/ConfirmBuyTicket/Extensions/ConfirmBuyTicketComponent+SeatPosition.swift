//  File name   : ConfirmBuyTicketComponent+SeatPosition.swift
//
//  Author      : vato.
//  Created date: 10/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ConfirmBuyTicket to provide for the SeatPosition scope.
// todo: Update ConfirmBuyTicketDependency protocol to inherit this protocol.
protocol ConfirmBuyTicketDependencySeatPosition: Dependency {
    // todo: Declare dependencies needed from the parent scope of ConfirmBuyTicket to provide dependencies
    // for the SeatPosition scope.
}

extension ConfirmBuyTicketComponent: SeatPositionDependency {

    // todo: Implement properties to provide for SeatPosition scope.
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
