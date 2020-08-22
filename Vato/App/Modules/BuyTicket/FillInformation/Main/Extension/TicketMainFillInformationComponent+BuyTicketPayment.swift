//  File name   : TicketMainFillInformationComponent+BuyTicketPayment.swift
//
//  Author      : khoi tran
//  Created date: 5/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of TicketMainFillInformation to provide for the BuyTicketPayment scope.
// todo: Update TicketMainFillInformationDependency protocol to inherit this protocol.
protocol TicketMainFillInformationDependencyBuyTicketPayment: Dependency {
    // todo: Declare dependencies needed from the parent scope of TicketMainFillInformation to provide dependencies
    // for the BuyTicketPayment scope.
}

extension TicketMainFillInformationComponent: BuyTicketPaymentDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authStream
    }
    

    // todo: Implement properties to provide for BuyTicketPayment scope.
}
