//  File name   : WalletComponent+PaymentMethodManage.swift
//
//  Author      : Dung Vu
//  Created date: 3/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase
/// The dependencies needed from the parent scope of Wallet to provide for the PaymentMethodManage scope.
// todo: Update WalletDependency protocol to inherit this protocol.
protocol WalletDependencyPaymentMethodManage: Dependency {
    // todo: Declare dependencies needed from the parent scope of Wallet to provide dependencies
    // for the PaymentMethodManage scope.
}

extension WalletComponent: PaymentMethodManageDependency {
    var firebaseDatabase: DatabaseReference {
        return self.dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return self.dependency.mutablePaymentStream
    }
    
    var profileStream: ProfileStream {
        return self.dependency.mProfileStream
    }
}
