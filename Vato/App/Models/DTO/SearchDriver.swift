//  File name   : SearchDriver.swift
//
//  Author      : Vato
//  Created date: 10/2/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore

struct SearchDriver: Decodable {
    private(set) var firebaseID: String = ""
    private(set) var name: String = ""

    private(set) var avatarURL: URL?
    private(set) var lat = 0.0
    private(set) var lng = 0.0

    private(set) var userID: Int = 0
    private(set) var cash: Double = 0
    private(set) var coin: Double = 0
    private(set) var service: VatoServiceType = .none
}

// MARK: Codable
extension SearchDriver {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firebaseID = try container.decode(String.self, forKey: .firebaseID)
        name = try container.decode(String.self, forKey: .name)
        avatarURL = try? container.decode(URL.self, forKey: .avatarURL)
        userID = try container.decode(key: .userID)
        cash = try container.decode(key: .cash)
        coin = try container.decode(key: .coin)
        service = try container.decode(VatoServiceType.self, forKey: .service)

        let locationContainer = try container.nestedContainer(keyedBy: LocationCodingKeys.self, forKey: .location)
        lat = try locationContainer.decode(key: .lat)
        lng = try locationContainer.decode(key: .lng)
    }

    /// Codable's keymap.
    private enum CodingKeys: String, CodingKey {
        case firebaseID = "firebaseId"
        case name = "fullName"
        case avatarURL = "avatarUrl"
        case userID = "id"
        case location
        case cash
        case coin
        case service
    }

    private enum LocationCodingKeys: String, CodingKey {
        case lat
        case lng = "lon"
    }
}
