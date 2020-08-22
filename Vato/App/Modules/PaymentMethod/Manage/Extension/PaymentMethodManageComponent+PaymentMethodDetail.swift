//  File name   : PaymentMethodManageComponent+PaymentMethodDetail.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of PaymentMethodManage to provide for the PaymentMethodDetail scope.
// todo: Update PaymentMethodManageDependency protocol to inherit this protocol.
protocol PaymentMethodManageDependencyPaymentMethodDetail: Dependency {
    // todo: Declare dependencies needed from the parent scope of PaymentMethodManage to provide dependencies
    // for the PaymentMethodDetail scope.
}

extension PaymentMethodManageComponent: PaymentMethodDetailDependency {
    var profileStream: ProfileStream {
        return self.dependency.profileStream
    }
}
