//  File name   : BuyTicketPaymentComponent+ResultBuyTicket.swift
//
//  Author      : vato.
//  Created date: 10/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BuyTicketPayment to provide for the ResultBuyTicket scope.
// todo: Update BuyTicketPaymentDependency protocol to inherit this protocol.
protocol BuyTicketPaymentDependencyResultBuyTicket: Dependency {
    // todo: Declare dependencies needed from the parent scope of BuyTicketPayment to provide dependencies
    // for the ResultBuyTicket scope.
}

extension BuyTicketPaymentComponent: ResultBuyTicketDependency {

    // todo: Implement properties to provide for ResultBuyTicket scope.
    var buyTicketStream: BuyTicketStreamImpl {
        return dependency.buyTicketStream
    }
}
