//
//  DetailRoute.swift
//  Vato
//
//  Created by MacbookPro on 5/15/20.
//  Copyright © 2020 Vato. All rights reserved.
//

struct DetailRoute: Codable {
    let address, code: String?
    let distance, duration: Int
    let fax: String?
    let id, latitude, longitude: Int?
    let name, note: String?
    let officeID, orderNumber: Int?
    let passing: Bool?
    let phone: String?
    let routeID, shuttleBefore, type, wayID: Int?

    enum CodingKeys: String, CodingKey {
        case address, code, distance, duration, fax, id, latitude, longitude, name, note
        case officeID = "officeId"
        case orderNumber, passing, phone
        case routeID = "routeId"
        case shuttleBefore, type
        case wayID = "wayId"
    }
}
struct DetailRouteInfo {
    var nameFrom: String?
    var nameTo: String?
    var listDetailRoute: [DetailRoute]?
    var departureDate: String?
    var departureTime: String?
}
