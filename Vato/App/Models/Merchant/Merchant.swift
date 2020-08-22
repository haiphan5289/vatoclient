//
//  Merchant.swift
//  Vato
//
//  Created by khoi tran on 10/24/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
struct Merchant : Codable {
    let basic : MerchantBasic?
    let categoryId : Int?
    let typeCode : String?
    
    var category: MerchantCategory?
    var attributes: [MerchantAttributeData]?
    
    enum CodingKeys: String, CodingKey {
        
        case basic = "basic"
        case categoryId = "categoryId"
        case typeCode = "typeCode"
        case attributes = "attributes"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        basic = try values.decodeIfPresent(MerchantBasic.self, forKey: .basic)
        categoryId = try values.decodeIfPresent(Int.self, forKey: .categoryId)
        typeCode = try values.decodeIfPresent(String.self, forKey: .typeCode)
        attributes = try values.decodeIfPresent([MerchantAttributeData].self, forKey: .attributes)
    }
    
}
