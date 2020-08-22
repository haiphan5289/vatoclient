//  File name   : BuyTicketPaymentComponent+NoteDelivery.swift
//
//  Author      : vato.
//  Created date: 10/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BuyTicketPayment to provide for the NoteDelivery scope.
// todo: Update BuyTicketPaymentDependency protocol to inherit this protocol.
protocol BuyTicketPaymentDependencyNoteDelivery: Dependency {
    // todo: Declare dependencies needed from the parent scope of BuyTicketPayment to provide dependencies
    // for the NoteDelivery scope.
}

extension BuyTicketPaymentComponent: NoteDeliveryDependency {

    // todo: Implement properties to provide for NoteDelivery scope.
}
