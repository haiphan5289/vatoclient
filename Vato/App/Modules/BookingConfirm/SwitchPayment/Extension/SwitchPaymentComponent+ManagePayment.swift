//
//  SwitchPaymentDependency+Add.swift
//  Vato
//
//  Created by khoi tran on 11/28/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

extension SwitchPaymentComponent: PaymentMethodManageDependency {
    var authenticated: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    var profileStream: ProfileStream {
        return dependency.mProfileStream
    }
}


extension SwitchPaymentComponent: PaymentAddCardDependency {
    
}

