//
//  ProductModifyData.swift
//  Vato
//
//  Created by khoi tran on 11/25/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import Foundation
struct ProductModifyData : Codable {
    let id : Int?
    let attributes : [MerchantAttributeData]?
    let eavAttributeSetId : Int?
    let type : String?
    let status : Int?
    let storeId : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case attributes = "attributes"
        case eavAttributeSetId = "eavAttributeSetId"
        case type = "type"
        case status = "status"
        case storeId = "storeId"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        attributes = try values.decodeIfPresent([MerchantAttributeData].self, forKey: .attributes)
        eavAttributeSetId = try values.decodeIfPresent(Int.self, forKey: .eavAttributeSetId)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        storeId = try values.decodeIfPresent(Int.self, forKey: .storeId)
    }
    
}
