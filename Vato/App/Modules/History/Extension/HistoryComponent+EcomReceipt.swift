//  File name   : HistoryComponent+EcomReceipt.swift
//
//  Author      : Dung Vu
//  Created date: 3/31/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of History to provide for the EcomReceipt scope.
// todo: Update HistoryDependency protocol to inherit this protocol.
protocol HistoryDependencyEcomReceipt: Dependency {
    // todo: Declare dependencies needed from the parent scope of History to provide dependencies
    // for the EcomReceipt scope.
}

extension HistoryComponent: EcomReceiptDependency {

    // todo: Implement properties to provide for EcomReceipt scope.
}
