//  File name   : AppState.swift
//
//  Author      : Vato
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RealmSwift

final class AppState: Object {
    /// Class's public properties.
    @objc public dynamic var recordID = 1

    /// Marker's statistics.
    @objc public dynamic var isMigratedToV530 = false
    @objc public dynamic var lastLatitude: CLLocationDegrees = 10.7664067
    @objc public dynamic var lastLongitude: CLLocationDegrees = 106.6935349

    // MARK: Class's static public methods
    public override static func primaryKey() -> String? {
        return "recordID"
    }
}

extension AppState {

    static func `default`() -> AppState {
        let realm = try? Realm()
        if let appState = realm?.object(ofType: AppState.self, forPrimaryKey: 1) {
            return appState
        } else {
            let appState = AppState()
            try? realm?.write {
                realm?.add(appState, update: .all)
            }
            return appState
        }
    }
}
