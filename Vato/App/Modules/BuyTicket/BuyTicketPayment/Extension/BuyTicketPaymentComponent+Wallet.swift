//  File name   : BuyTicketPaymentComponent+Wallet.swift
//
//  Author      : Dung Vu
//  Created date: 8/11/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of BuyTicketPayment to provide for the Wallet scope.
// todo: Update BuyTicketPaymentDependency protocol to inherit this protocol.
protocol BuyTicketPaymentDependencyWallet: Dependency {
    // todo: Declare dependencies needed from the parent scope of BuyTicketPayment to provide dependencies
    // for the Wallet scope.
}

extension BuyTicketPaymentComponent: WalletDependency {

    // todo: Implement properties to provide for Wallet scope.
}
