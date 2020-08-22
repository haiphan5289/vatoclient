//  File name   : ConfirmBuyTicketComponent+BuyTicketPayment.swift
//
//  Author      : vato.
//  Created date: 10/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ConfirmBuyTicket to provide for the BuyTicketPayment scope.
// todo: Update ConfirmBuyTicketDependency protocol to inherit this protocol.
protocol ConfirmBuyTicketDependencyBuyTicketPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of ConfirmBuyTicket to provide dependencies
    // for the BuyTicketPayment scope.
}

extension ConfirmBuyTicketComponent: BuyTicketPaymentDependency {

    // todo: Implement properties to provide for BuyTicketPayment scope.
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }

    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }

    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }
}
