//
//  TicketRoutes.swift
//  Vato
//
//  Created by THAI LE QUANG on 10/4/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

struct TicketRoutes: Codable {
    
    let destCode      : String?
    let destName      : String?
    let distance      : Double?
    let duration      : Double?
    let id            : Int?
    let kind          : String?
    let name          : String?
    let originCode    : String?
    let originName    : String?
    let price         : Double?
    let totalSchedule : Int?
    let routeStop : [RouteStop]?
    let promotion: PromotionTicket?
    let finalPrice    : Double?
    
    var description: String {
        return (originName ?? "") + " - " + (destName ?? "")
    }
    
     
    enum CodingKeys: String, CodingKey {
        
        case destCode       = "destCode"
        case destName       = "destName"
        case distance       = "distance"
        case duration       = "duration"
        case id             = "id"
        case kind           = "kind"
        case name           = "name"
        case originCode     = "originCode"
        case originName     = "originName"
        case price          = "price"
        case totalSchedule  = "totalSchedule"
        case routeStop      = "routeStop"
        case promotion      = "promotion"
        case finalPrice     = "finalPrice"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        destCode = try values.decodeIfPresent(String.self, forKey: .destCode)
        destName = try values.decodeIfPresent(String.self, forKey: .destName)
        distance = try values.decodeIfPresent(Double.self, forKey: .distance)
        duration = try values.decodeIfPresent(Double.self, forKey: .duration)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        kind = try values.decodeIfPresent(String.self, forKey: .kind)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        originCode = try values.decodeIfPresent(String.self, forKey: .originCode)
        originName = try values.decodeIfPresent(String.self, forKey: .originName)
        price = try values.decodeIfPresent(Double.self, forKey: .price)
        totalSchedule = try values.decodeIfPresent(Int.self, forKey: .totalSchedule)
        routeStop = try values.decodeIfPresent([RouteStop].self, forKey: .routeStop)
        promotion = try values.decodeIfPresent(PromotionTicket.self, forKey: .promotion)
        finalPrice = try values.decodeIfPresent(Double.self, forKey: .finalPrice)
    }
}

extension TicketRoutes: Equatable {
    static func == (lhs: TicketRoutes, rhs: TicketRoutes) -> Bool {
        return lhs.id == rhs.id
    }
}
struct PromotionTicket: Codable {
    let code: String?
    let type: PromotionTicketType?
    let value: Int?
    
    var valueResize: Int? {
        if type == .FLAT {
            return (value ?? 0) / 1000
        }
        return 0
    }
    
    enum CodingKeys: String, CodingKey {
           
           case code       = "code"
           case type       = "type"
           case value       = "value"
       }
       
       init(from decoder: Decoder) throws {
           let values = try decoder.container(keyedBy: CodingKeys.self)
           code = try values.decodeIfPresent(String.self, forKey: .code)
           type = try values.decodeIfPresent(PromotionTicketType.self, forKey: .type)
           value = try values.decodeIfPresent(Int.self, forKey: .value)
       }
}
extension TicketRoutes {
    func caculateAdditionalAmount() -> Double {
        guard let type = promotion?.type, let amount = price else {
            return 0
        }
        
        switch type {
        case .PERCENT:
            let value = Double(promotion?.value ?? 0)
            return (amount * value) / 100
        case .FLAT:
            return 0
        }
    }

}
enum PromotionTicketType: String, Codable {
    case PERCENT
    case FLAT
}



