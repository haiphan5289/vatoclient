//  File name   : Message.swift
//
//  Author      : Vato
//  Created date: 10/2/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

enum Status: Int, Decodable {
    case success = 200
    case accountBanned = 409
    case accountSpam = 429
}

struct Message<T: Decodable>: Decodable {
    let message: String
    let status: Status
    let data: T
}

// MARK: Codable
extension Message {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//    }

    /// Codable's keymap.
//    private enum CodingKeys: String, CodingKey {
//    }
}
