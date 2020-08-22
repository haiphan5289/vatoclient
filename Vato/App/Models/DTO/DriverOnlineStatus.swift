//  File name   : DriverOnlineStatus.swift
//
//  Author      : Dung Vu
//  Created date: 1/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct DriverOnlineStatus: Codable, ModelFromFireBaseProtocol {
    var location: Coordinate?
    var status: Int?
    let lastOnline: TimeInterval
}


