//
//  ListProductComponent+AddProduct.swift
//  Vato
//
//  Created by khoi tran on 11/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
extension ListProductComponent: AddProductDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenStream
    }
    
    var merchantDataStream: MerchantDataStream {
        return dependency.merchantDataStream
    }
}
