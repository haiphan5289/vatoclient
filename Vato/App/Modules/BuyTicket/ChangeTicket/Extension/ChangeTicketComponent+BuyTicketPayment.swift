//  File name   : ChangeTicketComponent+BuyTicketPayment.swift
//
//  Author      : MacbookPro
//  Created date: 11/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ChangeTicket to provide for the BuyTicketPayment scope.
// todo: Update ChangeTicketDependency protocol to inherit this protocol.
protocol ChangeTicketDependencyBuyTicketPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of ChangeTicket to provide dependencies
    // for the BuyTicketPayment scope.
}

extension ChangeTicketComponent: BuyTicketPaymentDependency {
    // todo: Implement properties to provide for BuyTicketPayment scope.
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
}
