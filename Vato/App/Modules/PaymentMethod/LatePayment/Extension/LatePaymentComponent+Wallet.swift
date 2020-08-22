//  File name   : LatePaymentComponent+Wallet.swift
//
//  Author      : Futa Corp
//  Created date: 3/13/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FirebaseDatabase

/// The dependencies needed from the parent scope of LatePayment to provide for the Wallet scope.
// todo: Update LatePaymentDependency protocol to inherit this protocol.
protocol LatePaymentDependencyWallet: Dependency {
    var firebaseDatabase: DatabaseReference { get }
}

extension LatePaymentComponent: WalletDependency {
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mProfileStream: ProfileStream {
        return self.profileStream
    }
}
