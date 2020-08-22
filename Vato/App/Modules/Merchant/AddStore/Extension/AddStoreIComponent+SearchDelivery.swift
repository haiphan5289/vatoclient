//
//  AddStoreInteractor+.swift
//  Vato
//
//  Created by khoi tran on 10/31/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RIBs

extension AddStoreComponent: SearchDeliveryDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    // todo: Implement properties to provide for SearchDelivery scope.
}
