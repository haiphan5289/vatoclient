//  File name   : HistoryComponent+RequestQuickSupport.swift
//
//  Author      : khoi tran
//  Created date: 3/5/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of History to provide for the RequestQuickSupport scope.
// todo: Update HistoryDependency protocol to inherit this protocol.
protocol HistoryDependencyRequestQuickSupport: Dependency {
    // todo: Declare dependencies needed from the parent scope of History to provide dependencies
    // for the RequestQuickSupport scope.
}

extension HistoryComponent: RequestQuickSupportDependency {

    // todo: Implement properties to provide for RequestQuickSupport scope.
}
