//  File name   : FareModifier.swift
//
//  Author      : Dung Vu
//  Created date: 9/28/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct FareModifier: Codable, ModelFromFireBaseProtocol {
    let id: Int
    let active: Bool
    let additionMin: Double
    let additionMax: Double
    let additionRatio: Double
    let additionAmount: Double
    let driverMax: Double
    let driverMin: Double
    let driverActiveAmount: Double
    let driverRatio: Double
    let clientMax: Double
    let clientMin: Double
    let clientRatio: Double
    let clientDelta: Double
    
    // Use for same price
    var clientFixed: Double?
}
