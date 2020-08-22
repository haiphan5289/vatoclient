//  File name   : BookNotify.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct BookNotify: Codable {
    var driverId: String?
    var requestId: String?
    var tripId: String?
    let timestamp: TimeInterval
}


