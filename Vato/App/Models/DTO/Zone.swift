//  File name   : Zone.swift
//
//  Author      : Dung Vu
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import Foundation

struct Zone: Codable, ModelFromFireBaseProtocol {
    let postcode: String?
    let name: String?
    let polyline: String?
    let id: Int
}
