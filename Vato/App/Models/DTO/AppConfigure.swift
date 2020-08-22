//
//  AppConfigure.swift
//  FaceCar
//
//  Created by tony on 10/2/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation

extension LinkConfigureType: Codable {}

struct AppLink: Codable, ModelFromFireBaseProtocol {
    let active: Bool
    let auth: Bool
    let name: String
    let type: LinkConfigureType
    var url: String?
    var iconURL: String?
    var min: Int?
    var max: Int?
    var options: [Double]?
}

struct AppConfigure: Codable, ModelFromFireBaseProtocol {
    var push_key: String?
    let app_link_configure: [AppLink]
    let topup_configure: [AppLink]
    let booking_radius: [BookRadius]
    var client_card_config: ClientCardConfig?
    var booking_configure: BookConfigure?
    var theme_storage_path_ios_client: String?
    
    func radius(from bookZoneId: Int, distance: Double) -> Double {
        let result: Double
        var bookRadius: BookRadius?
        
        find: for item in booking_radius where item.zoneId == bookZoneId || item.zoneId == ZoneConstant.vn {
            bookRadius = item
            if item.zoneId == bookZoneId {
                break find
            }
        }
        
        if let radius = bookRadius {
            // Change to m
            let minDistance = radius.minDistance * 1000
            if distance < minDistance {
                result = radius.min
            } else {
                let delta = radius.percent / 100
                let temp = radius.min + (distance / 1000 - radius.minDistance) * delta
                result = min(temp, radius.max)
            }
            
        } else { result = 2.0 }
        return result.round(to: 2)
    }
}
