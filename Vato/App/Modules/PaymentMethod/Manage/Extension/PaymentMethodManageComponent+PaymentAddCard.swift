//  File name   : PaymentMethodManageComponent+PaymentAddCard.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of PaymentMethodManage to provide for the PaymentAddCard scope.
// todo: Update PaymentMethodManageDependency protocol to inherit this protocol.
protocol PaymentMethodManageDependencyPaymentAddCard: Dependency {
    // todo: Declare dependencies needed from the parent scope of PaymentMethodManage to provide dependencies
    // for the PaymentAddCard scope.
}

extension PaymentMethodManageComponent: PaymentAddCardDependency {
    var authenticated: AuthenticatedStream {
        return self.dependency.authenticated
    }
    

    // todo: Implement properties to provide for PaymentAddCard scope.
}
