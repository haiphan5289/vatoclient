//
//  Model.swift
//  Vato
//
//  Created by khoi tran on 12/10/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

struct ProductMenuItem: Equatable {
    var basketItem: BasketStoreValueProtocol?
    var product: DisplayProduct
    
    static func == (lhs: ProductMenuItem, rhs: ProductMenuItem) -> Bool {
        return lhs.product == rhs.product
    }
}

struct BasketProductIem: BasketStoreValueProtocol {
    var note: String?
    var quantity: Int
}
