//  File name   : LocationHistory.swift
//
//  Author      : Phuc Tran
//  Created date: 8/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import Foundation
import RealmSwift

public final class LocationHistory: Object {
    /// Class's public properties.
    @objc public dynamic var recordID = UUID().uuidString

    @objc public dynamic var address: String?
    @objc public dynamic var name: String?

    @objc public dynamic var zoneID = 0
    @objc public dynamic var lat = 0.0
    @objc public dynamic var lng = 0.0

    @objc public dynamic var counter = 0
    @objc public dynamic var lastUsedTime = Date(timeIntervalSince1970: 0)

    // MARK: Class's static public methods
    public override static func primaryKey() -> String? {
        return "recordID"
    }
}

public extension LocationHistory {
    /// Search location history base on name
    ///
    /// - Parameter name: place's name
    /// - Returns: location history, might be nil
    @objc public static func search(_ name: String) -> LocationHistory? {
        do {
            let realm = try Realm()
            let history = realm.objects(LocationHistory.self).first(where: { $0.name == name })

            return history
        } catch _ {
            return nil
        }
    }

    @objc static func search(latitude lat: Double, longitude lng: Double, maxDistance distance: Double = 300.0, maxDay day: Int = 7) -> LocationHistory? {
        let coord = CLLocation(latitude: lat, longitude: lng)
        let circle = CLCircularRegion(center: coord.coordinate, radius: distance, identifier: "current_location")

        let time = TimeInterval(day * 24 * 60 * 60)
        return tryNotThrow ({
            let realm = try Realm()
            
            let histories = realm.objects(LocationHistory.self).filter {
                let coordinate = CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng)
                return circle.contains(coordinate)
                }
                .sorted(by: { l1, l2 in
                    let remain1 = Date().timeIntervalSince1970 - l1.lastUsedTime.timeIntervalSince1970
                    let remain2 = Date().timeIntervalSince1970 - l2.lastUsedTime.timeIntervalSince1970
                    let options = (remain1 < time, remain2 < time)
                    
                    switch options {
                    case (true, false):
                        return true
                        
                    case (false, true):
                        return false
                        
                    default:
                        if l1.counter == l2.counter {
                            let coord1 = CLLocation(latitude: l1.lat, longitude: l1.lng)
                            let coord2 = CLLocation(latitude: l2.lat, longitude: l2.lng)
                            let d1 = abs(coord1.distance(from: coord))
                            let d2 = abs(coord2.distance(from: coord))
                            return d1 < d2
                        } else {
                            return l1.counter > l2.counter
                        }
                    }
            })
            
            return histories.first
        }, default: nil)
    }
}
