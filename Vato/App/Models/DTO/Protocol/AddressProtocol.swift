//  File name   : AddressProtocol.swift
//
//  Author      : Vato
//  Created date: 9/25/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import GoogleMaps

protocol AddressProtocol {
    var coordinate: CLLocationCoordinate2D { get set}

    var name: String? { get set }
    var thoroughfare: String { get }

    var streetNumber: String { get }
    var streetName: String { get }
    var locality: String { get }
    var subLocality: String { get }
    var administrativeArea: String { get }
    var postalCode: String { get }
    var country: String { get }
    var lines: [String] { get }
    var isDatabaseLocal: Bool { get }
    var hashValue: Int { get }
    var zoneId: Int { get set }
    var favoritePlaceID: Int64 { get }
    var isOrigin: Bool { get set }
    var counter: Int { get set }
    
    var placeId: String? { get set }
    var distance: Double? { get set }
    var nameFavorite: String? { get }
    var descriptionFavorite: String? { get }
    var isFavoritePlace: Bool { get }
    var typeFavorite: Int { get }
    var active: Bool { get }
    
    func increaseCounter()
    mutating func update(isOrigin: Bool)
    mutating func update(zoneId: Int)
    mutating func update(placeId: String?)
    mutating func update(coordinate: CLLocationCoordinate2D?)
    mutating func update(subLocality: String?)
    mutating func update(name: String?)
}

extension AddressProtocol {
    var isFavoritePlace: Bool {
        return favoritePlaceID > 0
    }
    
    var active: Bool {
        return true
    }
    
    var typeKindFavorite: FavoritePlaceType {
        return FavoritePlaceType(rawValue: typeFavorite).orNil(.Orther)
    }
    
    @discardableResult
    func createMarker(for mapView: GMSMapView,
                      customMarker: (() -> GMSMarker)? = nil,
                      with icon: UIImage? = nil,
                      block: ((GMSMarker) -> Void)? = nil) -> GMSMarker {
        let marker = (customMarker?() ?? GMSMarker(position: coordinate)) >>> {
            block?($0) ?? {
                $0.icon = icon
                $0.title = thoroughfare
            }($0)
            $0.map = mapView
        }
        marker.tracksViewChanges = false
        return marker
    }

    var primaryText: String {
        let v = name ?? ""
        let text = !v.isEmpty ? v : thoroughfare
        return (text.lowercased() == Text.unnamedRoad.text.lowercased() ? Text.unnamedRoad.localizedText : text.capitalized)
    }

    var secondaryText: String {
        return subLocality
    }
    
    func isValidCoordinate() -> Bool {
        return (coordinate.latitude != 0 && coordinate.longitude != 0)
    }
}
