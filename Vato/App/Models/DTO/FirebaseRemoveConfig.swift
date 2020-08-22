//
//  FirebaseRemoveConfig.swift
//  Vato
//
//  Created by THAI LE QUANG on 9/16/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import UIKit

struct FirebaseRemoveConfig: Codable, ModelFromFireBaseProtocol {
    let zoneId: Int
    let maxZoom: Double
    let minZoom: Double
}
