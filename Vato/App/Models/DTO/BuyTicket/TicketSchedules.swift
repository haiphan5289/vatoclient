
import Foundation

import Foundation
struct TicketSchedules : Codable {
    let kindId : Int?
    let timeStartId : Int?
    let wayId : Int?
    let id : Int?
    let kind : String?
    let time : String?
    let promotion: PromotionTicket?
    
    enum CodingKeys: String, CodingKey {
        
        case kindId = "kindId"
        case timeStartId = "timeStartId"
        case wayId = "wayId"
        case id = "id"
        case kind = "kind"
        case time = "time"
        case promotion = "promotion"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        kindId = try values.decodeIfPresent(Int.self, forKey: .kindId)
        timeStartId = try values.decodeIfPresent(Int.self, forKey: .timeStartId)
        wayId = try values.decodeIfPresent(Int.self, forKey: .wayId)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        kind = try values.decodeIfPresent(String.self, forKey: .kind)
        time = try values.decodeIfPresent(String.self, forKey: .time)
        promotion = try values.decodeIfPresent(PromotionTicket.self, forKey: .promotion)
    }

}

