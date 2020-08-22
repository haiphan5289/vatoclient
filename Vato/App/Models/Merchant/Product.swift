//
//  Product.swift
//  Vato
//
//  Created by khoi tran on 11/21/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation


enum ProductType: String {
    case SIMPLE = "SIMPLE"
}


struct DisplayProductCategory: Codable, StoreCategoryDisplayProtocol {
    var name: String?
    var id: Int?
    var products: [DisplayProduct]?
}

struct DisplayProduct : Codable, Equatable, StoreProductDisplayProtocol, Hashable {
    var productId : Int?
    var productName : String?
    var productPrice : Double?
    var images : [String]?
    var productDescription : String?
    var productIsOpen : Bool?
    var category : Int?
    var sku : String?
    var specialPrice : Double?
    var finalPrice : Double?
    var isPromo : Bool?
    var specialFromDate : String?
    var specialToDate : String?
    var qty : Int?
    var status : Int?
    var cacheLocal: Bool { return false }
    
    var name: String? {
        return productName
    }
    var price: Double? {
        return finalPrice
    }
    var description: String? {
        return productDescription
    }
    var imageURL: String? {
        return images?.first?.components(separatedBy: ";").first
    }
    
    func hash(into hasher: inout Hasher) {
        hasher = Hasher()
        let id = productId ?? 0
        hasher.combine(id)
    }
    
    
    enum CodingKeys: String, CodingKey {
        
        case productId = "productId"
        case productName = "productName"
        case productPrice = "productPrice"
        case images = "images"
        case productDescription = "productDescription"
        case productIsOpen = "productIsOpen"
        case category = "category"
        case sku = "sku"
        case specialPrice = "specialPrice"
        case finalPrice = "finalPrice"
        case isPromo = "isPromo"
        case specialFromDate = "specialFromDate"
        case specialToDate = "specialToDate"
        case qty = "qty"
        case status = "status"
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        productId = try values.decodeIfPresent(Int.self, forKey: .productId)
        productName = try values.decodeIfPresent(String.self, forKey: .productName)
        productPrice = try values.decodeIfPresent(Double.self, forKey: .productPrice)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        productDescription = try values.decodeIfPresent(String.self, forKey: .productDescription)
        productIsOpen = try values.decodeIfPresent(Bool.self, forKey: .productIsOpen)
        category = try values.decodeIfPresent(Int.self, forKey: .category)
        sku = try values.decodeIfPresent(String.self, forKey: .sku)
        specialPrice = try values.decodeIfPresent(Double.self, forKey: .specialPrice)
        finalPrice = try values.decodeIfPresent(Double.self, forKey: .finalPrice)
        isPromo = try values.decodeIfPresent(Bool.self, forKey: .isPromo)
        specialFromDate = try values.decodeIfPresent(String.self, forKey: .specialFromDate)
        specialToDate = try values.decodeIfPresent(String.self, forKey: .specialToDate)
        qty = try values.decodeIfPresent(Int.self, forKey: .qty)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
    }
    
    static func == (lhs: DisplayProduct, rhs: DisplayProduct) -> Bool {
        return lhs.productId == rhs.productId
    }
    
    
    var isAppliedSpecialPrice: Bool {
//        guard let specialFromDate = Date.date(from: self.specialFromDate, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") else { return false }
//
//        if let specialToDate = Date.date(from: self.specialToDate, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
//            let date = Date().toGMT()
//            let result = specialFromDate > specialToDate ? false : specialFromDate...specialToDate ~= date
//            let different = productPrice != finalPrice
//            return result && different
//
//        } else {
//            return true
//        }
       return productPrice != finalPrice
    }
}

extension DisplayProduct {
    init?(order: OrderItem?) {
        guard let order = order else { return nil }
        var item = DisplayProduct()
        item.productId = order.productId
        item.productName = order.name
        item.productPrice = Double(order.basePrice ?? 0)
        var images: [String] = []
        images.addOptional(order.images)
        item.images = images
        item.finalPrice = Double(order.basePriceInclTax ?? 0)
        self = item
    }
    
    init(quoteItem: QuoteItem) {
        var item = DisplayProduct()
        var images: [String] = []
        images.addOptional(quoteItem.images?.trim())
        item.images = images
        item.productId = quoteItem.productId
        item.productName = quoteItem.name
        item.productPrice = quoteItem.basePrice
        item.finalPrice = quoteItem.basePriceInclTax ?? 0
        self = item
    }
}

