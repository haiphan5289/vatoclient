//  File name   : DriverSearch.swift
//
//  Author      : Dung Vu
//  Created date: 1/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import FwiCore

struct DriverSearch: Codable, Equatable {
    var firebaseId: String?
    var name: String?
    var avatarUrl: String?
    var location: Coordinate?
    let id: Int
    var cash: Double = 0
    var coin: Double = 0
    let service: Int
    let satisfied: Bool
    
    let favorite: Coordinate?
    var priority: Int = 0
    var taxiBrand: Int?
    
    static func ==(lhs: DriverSearch, rhs: DriverSearch) -> Bool {
        return lhs.firebaseId == rhs.firebaseId
    }
}

