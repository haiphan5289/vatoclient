//  File name   : UserDebtDTO.swift
//
//  Author      : Futa Corp
//  Created date: 3/19/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct UserDebtDTO: Codable {
    let amount: Double
    let tripIDs: [String]
    let failCards: [String]
}

// MARK: Codable
extension UserDebtDTO {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//    }

    /// Codable's keymap.
    private enum CodingKeys: String, CodingKey {
        case amount
        case tripIDs = "tripIds"
        case failCards
    }
}
