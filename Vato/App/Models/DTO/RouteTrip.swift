//  File name   : RouteTrip.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct RouteInformation: Codable {
    let text: String
    let value: Double
}

struct RouteTrip: Codable {
    let distance: RouteInformation
    let duration: RouteInformation
}


