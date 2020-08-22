//  File name   : BookRadius.swift
//
//  Author      : Dung Vu
//  Created date: 1/16/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct BookRadius: Codable, ModelFromFireBaseProtocol {
    let zoneId: Int
    let max: Double
    let min: Double
    let minDistance: Double
    let percent: Double
}

