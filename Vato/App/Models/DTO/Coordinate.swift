//  File name   : Coordinate.swift
//
//  Author      : Futa Corp
//  Created date: 1/8/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation

struct Coordinate: Codable, ModelFromFireBaseProtocol, Equatable {
    let lat: Double
    let lng: Double
    
    var name: String?
    
    init(from lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    
    var valid: Bool {
        return lat != 0 || lng != 0
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let l = try? values.decode(String.self, forKey: .lat), let lat = Double(l)  {
            self.lat = lat
        } else {
           lat = try values.decode(Double.self, forKey: .lat)
        }
        
        if let l = try? values.decode(String.self, forKey: .lng), let lat = Double(l)  {
            self.lng = lat
        } else {
           lng = try values.decode(Double.self, forKey: .lng)
        }
        
        self.name = try values.decodeIfPresent(String.self, forKey: .name)
    }
    
}

// MARK: Codable
extension Coordinate {

    /// Codable's keymap.
    private enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case lng = "lon"
        case name
    }
    
    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: lng)
    }
}
