//
//  MerchantDetailComponent+AddStore.swift
//  Vato
//
//  Created by khoi tran on 10/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RIBs


extension MerchantDetailComponent: AddStoreDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var merchantDataStream: MerchantDataStream {
        return dependency.merchantDataStream
    }
    
    
}


