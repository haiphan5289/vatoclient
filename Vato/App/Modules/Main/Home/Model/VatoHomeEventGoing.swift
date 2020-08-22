//  File name   : VatoHomeEventGoing.swift
//
//  Author      : Dung Vu
//  Created date: 5/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

enum VatoHomeEventType: String, Codable {
    case bookService = "RIDING"
    case delivery = "DELIVERY"
    case busline = "BUSLINE"
    case food = "FOOD"
    case market = "MARKET"
    
    var priority: Int {
        switch self {
        case .food:
            return 0
        case .bookService:
            return 1
        case .market:
            return 2
        case .delivery:
            return 3
        case .busline:
            return 4
        }
    }
    
    var historyType: HistoryItemType? {
        switch self {
        case .bookService:
            return .booking
        case .delivery:
            return .expressUrBan
        case .food:
            return .food
        case .market:
            return .supply
        case .busline:
            return .busline
        }
    }
    
    var icon: String {
        switch self {
        case .bookService:
            return "ic_home_bike_s"
        case .delivery:
            return "ic_home_delivery_s"
        case .busline:
            return "ic_home_ticket_s"
        case .food:
            return "ic_home_location_s"
        case .market:
            return "ic_market_s"
        }
    }
}
// MARK: - Data
struct VatoHomeEventGoing: Codable {
    var id: String?
    let service_id: Int
    var status: String?
    var user_id: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try values.decodeIfPresent(String.self, forKey: .id)
            service_id = try values.decode(Int.self, forKey: .service_id)
            status = try values.decodeIfPresent(String.self, forKey: .status)
            user_id = try values.decode(Int.self, forKey: .user_id)
        } catch {
            throw error
        }
    }
}

struct VatoHomeEventGoingIdentifyGroup: Codable {
    let segment: VatoHomeEventType
    let service_ids: [Int]
    let title: String
}

// MARK: - Display
final class VatoHomeGroupEventGoing: Comparable, CustomStringConvertible {
    let service: VatoHomeEventType
    var items: [VatoHomeEventGoing] = []
    let title: String
    
    var description: String {
        return "\(title) <b>(\(items.count))</b>"
    }
    
    
    init?(service: VatoHomeEventType?, title: String) {
        guard let service = service else { return nil }
        self.service = service
        self.title = title
    }
    
    static func ==(lhs: VatoHomeGroupEventGoing, rhs: VatoHomeGroupEventGoing) -> Bool {
        return lhs.service.priority == rhs.service.priority && lhs.items.count == rhs.items.count
    }
    
    static func <(lhs: VatoHomeGroupEventGoing, rhs: VatoHomeGroupEventGoing) -> Bool {
        return lhs.service.priority < rhs.service.priority
    }
}
// MARK: - Response
struct VatoHomeEventGoingResponse: Codable {
    var events: [VatoHomeEventGoing]?
    let groups: [VatoHomeEventGoingIdentifyGroup]
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            events = try values.decodeIfPresent([VatoHomeEventGoing].self, forKey: .events)
            groups = try values.decode([VatoHomeEventGoingIdentifyGroup].self, forKey: .groups)
        } catch {
            throw error
        }
    }
    
    func loadGroup() -> [VatoHomeGroupEventGoing] {
        var group: [VatoHomeEventType: VatoHomeGroupEventGoing] = [:]
        events?.forEach({ (e) in
            guard let f = groups.first(where: { $0.service_ids.contains(e.service_id)} ) else {
                return
            }
            let current = group[f.segment] ?? VatoHomeGroupEventGoing(service: f.segment, title: f.title)
            current?.items.append(e)
            group[f.segment] = current
        })
        let result = group.map { $0.value }.sorted(by: <)
        return result
    }
}



