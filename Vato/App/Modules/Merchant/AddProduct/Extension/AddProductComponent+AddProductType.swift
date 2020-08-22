//
//  AddProductComponent+AddProductType.swift
//  Vato
//
//  Created by khoi tran on 11/8/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
extension AddProductComponent: AddProductTypeDependency {
    var authenStream: AuthenticatedStream {
        return dependency.authenticatedStream
    }
    
    var merchantDataStream: MerchantDataStream {
        return dependency.merchantDataStream
    }
    
    
}
