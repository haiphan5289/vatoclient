//  File name   : BuyTicketPaymentComponent+TopUpByThirdParty.swift
//
//  Author      : Dung Vu
//  Created date: 3/23/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BuyTicketPayment to provide for the TopUpByThirdParty scope.
// todo: Update BuyTicketPaymentDependency protocol to inherit this protocol.
protocol BuyTicketPaymentDependencyTopUpByThirdParty: Dependency {
    // todo: Declare dependencies needed from the parent scope of BuyTicketPayment to provide dependencies
    // for the TopUpByThirdParty scope.
}

extension BuyTicketPaymentComponent: TopUpByThirdPartyDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    // todo: Implement properties to provide for TopUpByThirdParty scope.
}
