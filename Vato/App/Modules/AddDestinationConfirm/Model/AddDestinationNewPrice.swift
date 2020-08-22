//
//  AddDestinationNewPrice.swift
//  FC
//
//  Created by khoi tran on 3/24/20.
//  Copyright © 2020 Vato. All rights reserved.
//

import Foundation
import CoreLocation

struct AddDestinationNewPrice: Codable {
    let fee: Int
    let final_fare: UInt64
}

struct TripWayPoint: Codable, Equatable {
    let lat: Double
    let lon: Double
    let address: String
    var name: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    static func ==(lhs: TripWayPoint, rhs: TripWayPoint) -> Bool {
        return lhs.lat == rhs.lat && lhs.lon == rhs.lon && lhs.address == rhs.address
    }
}

struct AddDestinationTripInfo: Codable {
    struct Trip: Codable {
        struct Source: Codable {
            var userType: String?
            var editable: Bool?
        }
        
        struct ExtraData: Codable {
            var startLocation: Coordinate?
            var endLocation: Coordinate?
        }
        
        var fromSource: Source?
        var startLocation: Coordinate? {
            return extraData?.startLocation
        }
        var startName: String?
        var startAddress: String?
        var endAddress: String?
        var endName: String?
        var serviceId: Int
        var promotionValue: UInt64?
        var type: Int
        var wayPoints: [TripWayPoint]?
        
        var endLat: Double?
        var endLon: Double?
        var endLocation: Coordinate? {
            return extraData?.endLocation
        }
        
        var startLat: Double?
        var startLon: Double?
        
        var additionPrice: UInt64?
        var price: UInt64
        var farePrice: UInt64?
        var fareClientSupport: UInt64?
        var extraData: ExtraData?
        var oPrice: UInt64 {
            let fPrice = self.farePrice.orNil(0)
            let bookPrice = (fPrice > 0 && self.price != 0) ? fPrice : self.price
            return bookPrice + self.additionPrice.orNil(0)
        }
        
        var fPrice: UInt64 {
            let r = oPrice
            let p = (promotionValue ?? 0) + fareClientSupport.orNil(0)
            return r > p ? r - p : 0
        }
    }
    var trip: Trip?
}

struct AddDestinationInfo: AddressProtocol {
    var coordinate: CLLocationCoordinate2D = .init()
    var name: String? = ""
    var thoroughfare: String = ""
    var streetNumber: String = ""
    var streetName: String = ""
    var locality: String = ""
    var subLocality: String = ""
    var administrativeArea: String = ""
    var postalCode: String = ""
    var country: String = ""
    var lines: [String] = []
    var isDatabaseLocal: Bool = false
    var hashValue: Int = 150
    var zoneId: Int = 0
    var isOrigin: Bool = false
    var counter: Int = 0
    var placeId: String?
    var distance: Double?
    var favoritePlaceID: Int64 = 0
    var nameFavorite: String?
    var descriptionFavorite: String?
    var typeFavorite: Int {
        return -1
    }
    
    func increaseCounter() {}
    func update(isOrigin: Bool) {}
    func update(zoneId: Int) {}
    func update(placeId: String?) {}
    func update(subLocality: String?) {}
    func update(coordinate: CLLocationCoordinate2D?) {}
    func update(name: String?) {}
    
    init() {}
    
    init(coordinate: CLLocationCoordinate2D, name: String?, subLocality: String) {
        self.coordinate = coordinate
        self.name = name
        self.subLocality = subLocality
    }
}


