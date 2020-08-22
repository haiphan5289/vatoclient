//
//  DestinationPoint.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/3/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

struct TicketDestinationPoint: Codable, Hashable, Equatable {
    
    let destCode: String?
    let destName: String?
    let originCode: String?
    let originName: String?
    
    enum CodingKeys: String, CodingKey {
        
        case destCode = "destCode"
        case destName = "destName"
        case originCode = "originCode"
        case originName = "originName"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        destCode = try values.decodeIfPresent(String.self, forKey: .destCode)
        destName = try values.decodeIfPresent(String.self, forKey: .destName)
        originCode = try values.decodeIfPresent(String.self, forKey: .originCode)
        originName = try values.decodeIfPresent(String.self, forKey: .originName)
    }
    
    static func == (lhs: TicketDestinationPoint, rhs: TicketDestinationPoint) -> Bool{
        return lhs.originCode == rhs.originCode && lhs.destCode == rhs.destCode
    }
}
