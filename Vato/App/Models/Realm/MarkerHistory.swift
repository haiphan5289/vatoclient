//  File name   : MarkerHistory.swift
//
//  Author      : Vato
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import Foundation
import RealmSwift
import VatoNetwork

final class MarkerHistory: Object, Comparable {
    static func < (lhs: MarkerHistory, rhs: MarkerHistory) -> Bool {
        if lhs.lastUsedTime != rhs.lastUsedTime {
            return lhs.lastUsedTime < rhs.lastUsedTime
        } else {
            return lhs.counter < rhs.counter
        }
    }
    
    /// Class's public properties.
    @objc public dynamic var markerID = UUID().uuidString

    /// Marker's statistics.
    @objc public dynamic var lastUsedTime = Date(timeIntervalSince1970: 0)
    @objc public dynamic var counter = 0
    @objc public dynamic var lat = 0.0
    @objc public dynamic var lng = 0.0

    @objc public dynamic var isOrigin = true
    @objc public dynamic var isVerifiedV2 = false

    /// GMSAddress's properties.
    @objc public dynamic var name: String?
    @objc public dynamic var thoroughfare: String?
    @objc public dynamic var locality: String?
    @objc public dynamic var subLocality: String?
    @objc public dynamic var administrativeArea: String?
    @objc public dynamic var postalCode: String?
    @objc public dynamic var country: String?
    @objc public dynamic var placeId: String?
    @objc public dynamic var favoritePlaceID: Int64 = 0
    @objc dynamic var nameFavorite: String?
    @objc dynamic var descriptionFavorite: String?

    let lines = List<String>()

    var address: AddressProtocol {
        return Address(placeId: placeId,
                       coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                       name: name ?? "",
                       thoroughfare: thoroughfare ?? "",
                       locality: locality ?? "",
                       subLocality: subLocality ?? "",
                       administrativeArea: administrativeArea ?? "",
                       postalCode: postalCode ?? "",
                       country: country ?? "",
                       lines: Array(lines),
                       zoneId: 0,
                       isOrigin: false,
                       counter: counter,
                       distance: nil,
                       favoritePlaceID: favoritePlaceID)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
    }

    // MARK: Class's static public methods
    public override static func primaryKey() -> String? {
        return "markerID"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MarkerHistory  else {
            return false
        }
        
        return self.coordinate == other.coordinate
    }
}

// MARK: Class's constructors
extension MarkerHistory {
    convenience init(with address: GoogleModel.Result, primaryText: String, secondaryText: String) {
        self.init()
        lastUsedTime = Date()
        counter = 0

        update(address: address, primaryText: primaryText, secondaryText: secondaryText)
    }
    convenience init(with address: GoogleModel.Result) {
        self.init()
        lastUsedTime = Date()
        counter = 0

        update(address: address)
    }
    
    convenience init(with placeDetail: MapModel.PlaceDetail) {
        self.init()
        lastUsedTime = Date()
        counter = 0
        
        update(place: placeDetail)
    }
    
    convenience init(with place: MapModel.Place) {
        self.init()
        lastUsedTime = Date()
        counter = 0
        
        update(place: place)
    }

    convenience init(with address: AddressProtocol) {
        self.init()
        lastUsedTime = Date()
        counter = address.counter
        lat = address.coordinate.latitude
        lng = address.coordinate.longitude
        placeId = address.placeId
        name = address.name?.capitalized
        thoroughfare = address.thoroughfare.capitalized
        locality = address.locality
        subLocality = address.subLocality
        administrativeArea = address.administrativeArea
        postalCode = address.postalCode
        country = address.country

        if address.lines.count > 0 {
            address.lines.forEach { lines.append($0) }
        }
    }
}

// MARK: Class's public methods
extension MarkerHistory {
    func update(address: GoogleModel.Result, primaryText: String, secondaryText: String) {
        name = address.name?.capitalized ?? ""
        lat = address.geometry.location.lat
        lng = address.geometry.location.lng
        placeId = address.placeId
        let addressComponents = address.addressComponents
        if
            let streetNumber = addressComponents.first(where: { $0.types.contains("street_number") })?.longName,
            let route = addressComponents.first(where: { $0.types.contains("route") })?.longName
        {
            thoroughfare = "\(streetNumber.uppercased()) \(route.capitalized)"
        } else {
            thoroughfare = address.name?.capitalized ?? ""
        }

        locality = addressComponents.first(where: { $0.types.contains("administrative_area_level_2") })?.longName
        subLocality = addressComponents.first(where: { $0.types.contains("administrative_area_level_3") })?.longName
        administrativeArea = addressComponents.first(where: { $0.types.contains("administrative_area_level_1") })?.longName
//        postalCode =
        country = addressComponents.first(where: { $0.types.contains("country") })?.longName
        lines.append(secondaryText)
    }

    func update(address: GoogleModel.Result) {
        lat = address.geometry.location.lat
        lng = address.geometry.location.lng
        placeId = address.placeId
        let addressComponents = address.addressComponents
        if let route = addressComponents.first(where: { $0.types.contains("route") })?.longName {
            if let streetNumber = addressComponents.first(where: { $0.types.contains("street_number") })?.longName {
                let text = "\(streetNumber.uppercased()) \(route.capitalized)"
                thoroughfare = text

                if name == nil {
                    name = text
                } else if name?.lowercased().contains(text.lowercased()) == true {
                    name = text
                }
            } else {
                let text = route.capitalized
                thoroughfare = text

                if name == nil {
                    name = text
                } else if name?.lowercased().contains(text.lowercased()) == true {
                    name = text
                }
            }
        } else {
            thoroughfare = Text.unnamedRoad.text

            if name == nil {
                name = Text.unnamedRoad.text
            } else if name?.lowercased().contains(Text.unnamedRoad.text.lowercased()) == true {
                name = Text.unnamedRoad.text
            }
        }

        locality = addressComponents.first(where: { $0.types.contains("administrative_area_level_2") })?.longName
        subLocality = addressComponents.first(where: { $0.types.contains("administrative_area_level_3") })?.longName
        administrativeArea = addressComponents.first(where: { $0.types.contains("administrative_area_level_1") })?.longName
//        postalCode =
        country = addressComponents.first(where: { $0.types.contains("country") })?.longName

        lines.removeAll()
        lines.append(address.formattedAddress)
    }
    
    func update(place: MapModel.Place) {
        name = place.primaryName
        lat = place.location?.lat ?? 0
        lng = place.location?.lon ?? 0

        locality = place.primaryName
        subLocality = place.address
        administrativeArea = place.address
        lines.append(place.address ?? "")
        placeId = place.placeId
        if place.isFavorite == true {
            favoritePlaceID = Int64(place.placeId ?? "0") ?? 0
        }
    }
    
    func update(place: MapModel.PlaceDetail) {
        name = place.name
        lat = place.location?.lat ?? 0
        lng = place.location?.lon ?? 0
        placeId = place.placeId
        locality = place.name
        subLocality = place.fullAddress
        administrativeArea = place.fullAddress
        lines.append(place.fullAddress ?? "")
        
        let isFavorite = place.isFavorite ?? false
        if isFavorite {
            favoritePlaceID = Int64(place.placeId ?? "0") ?? 0
        }
    }
}

