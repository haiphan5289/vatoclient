//  File name   : PriceAddition.swift
//
//  Author      : Dung Vu
//  Created date: 9/29/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct PriceAddition: Codable, CustomStringConvertible {
    let active: Bool
    let price: UInt32

    var description: String {
        guard price > 0 else {
            return "Đặt lại"
        }
        return "+\(price.currency)"
    }
}

struct BookConfigure: Codable {
    let message: String
    let message_in_peak_hours: String
    let distance_allow: UInt32
    let out_country: Bool
    let hide_destination: Bool

    let price_maximum_multi: Int
    let suggestion_max_day: Int
    let suggestion_max_distance: Int
    let request_booking_timeout: Double
}

struct ClientCardConfig: Codable {
    let active: Bool
    let max_card: Int
    let max_trip_price: Double
}

struct TipConfig: Codable, ModelFromFireBaseProtocol {
    let booking_price_additional: [PriceAddition]
    let booking_configure: BookConfigure
    var api_fare_settings: Bool?
    var client_card_config: ClientCardConfig?
}
