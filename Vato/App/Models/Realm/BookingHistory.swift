//  File name   : BookingHistory.swift
//
//  Author      : Vato
//  Created date: 10/10/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RealmSwift

final class BookingHistory: Object {
    /// Class's public properties.
    @objc public dynamic var bookingID = UUID().uuidString

    /// Marker's statistics.
    @objc public dynamic var lastUsedTime = Date(timeIntervalSince1970: 0)
    @objc public dynamic var counter = 0

    @objc public dynamic var hour: Double = 0.0
    let tips = List<Double>()

    @objc public dynamic var originMarker: MarkerHistory?
    @objc public dynamic var destination1Marker: MarkerHistory?

    // MARK: Class's static public methods
    public override static func primaryKey() -> String? {
        return "bookingID"
    }
}
