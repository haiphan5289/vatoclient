//
//  ContractModel.swift
//  Vato
//
//  Created by an.nguyen on 8/21/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation

struct CarContract: Codable {
    let pickup: String?
    let pickup_time: Double?
    let drop: String?
    let drop_time: Double?
    let trip_type: String?
    let num_of_people:Int?
    let num_of_seat: Int?
    let vehicle_rank: String?
    let driver_gender: String?
    let require_bill: Bool?
    let note: String?
    let other_grant: Bool?
    let other_name: String?
    let other_phone: String?
    let other_email: String?
}

struct OptionContract: Codable {
    let trip_types: [String]?
    let seats: [String]?
    let ranks: [String]?
    let gender_default: String?
}
