//  File name   : HistoryComponent+CheckOut.swift
//
//  Author      : Dung Vu
//  Created date: 3/31/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FirebaseDatabase
/// The dependencies needed from the parent scope of History to provide for the CheckOut scope.
// todo: Update HistoryDependency protocol to inherit this protocol.
protocol HistoryDependencyCheckOut: Dependency {
    // todo: Declare dependencies needed from the parent scope of History to provide dependencies
    // for the CheckOut scope.
}

extension HistoryComponent: CheckOutDependency {
    var firebaseDatabase: DatabaseReference {
        return Database.database().reference()
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    // todo: Implement properties to provide for CheckOut scope.
}
