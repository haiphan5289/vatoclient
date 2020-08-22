//
//  TicketBought.swift
//  Vato
//
//  Created by HaiPhan on 10/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

//
//  TiCketBought.swift
//  Vato
//
//  Created by HaiPhan on 10/11/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation

struct TicketBought: Codable {
    let ID: String?
    let Code: String?
    let ConfirmCode: String?
    let CustName, CustCode, CustID, CustEmail: String?
    let CustMoible: String?
    let CustMobile2, CustSN, CustAddress, CustCity: String?
    let CustCountry, CustState: String?
    let CustBirthDay: String?
    let RouteID: Int?
    let RouteName, DepartureDate, DepartureTime: String?
    let NumOfTiCket: Int?
    let CarBookingID: String?
    let SeatIDS: [Int]?
    let SeatNames: [String]
    let OfficePickupID: Int?
    let PickUpStreet: String?
    let SeatDiscounts: [Int]
    let Passengers: [Passenger]?
    let EnglishTicket: Int?
    let Locale: String?
    let Version: Int?
    let Payment: Bool?
    let CountChangeTicket, Status, Price, Promotion: Int?
    let Discount, FeeCancel, FeeChargeCancel, FeeChangeSeat: Int?
    let OriginCode, DestCode, OriginName, DestName: String?
    let CreateAt: String?
    let UpdateAt: String?
    
    enum CodingKeys: String, CodingKey {
        case ID, Code, ConfirmCode, CustName, CustCode
        case CustID = "CustId"
        case CustEmail, CustMoible, CustMobile2, CustSN, CustAddress, CustCity, CustCountry, CustState, CustBirthDay
        case RouteID = "RouteID"
        case RouteName, DepartureDate, DepartureTime, NumOfTiCket
        case CarBookingID = "CarBookingId"
        case SeatIDS = "SeatIDS"
        case SeatNames
        case OfficePickupID = "OfficePickupID"
        case PickUpStreet, SeatDiscounts, Passengers, EnglishTicket, Locale, Version, Payment, CountChangeTicket, Status, Price, Promotion, Discount, FeeCancel, FeeChargeCancel, FeeChangeSeat, OriginCode, DestCode, OriginName, DestName, CreateAt, UpdateAt
    }
}

// MARK: - Passenger
struct Passenger: Codable {
    let ID: String?
    let CustName, CustMobile, CustSN: String?
}

// MARK: - EnCode/deCode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
