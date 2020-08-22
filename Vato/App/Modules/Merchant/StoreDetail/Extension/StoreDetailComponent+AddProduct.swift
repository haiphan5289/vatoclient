//
//  StoreDetailComponent+AddProduct.swift
//  Vato
//
//  Created by khoi tran on 11/7/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation



extension StoreDetailComponent: AddProductDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
}



extension StoreDetailComponent: ListProductDependency {
    var authenStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var merchantDataStream: MerchantDataStream {
        return dependency.merchantDataStream
    }
    
    
}
