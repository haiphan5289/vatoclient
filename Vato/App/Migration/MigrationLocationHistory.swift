//  File name   : MigrationLocationHistory.swift
//
//  Author      : Vato
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FirebaseAuth
import FirebaseDatabase
import Foundation
import FwiCore
import RealmSwift

final class MigrationLocationHistory {
    /// Class's public properties.

    /// Class's constructors.
    init(database: DatabaseReference) {
        self.database = database
    }

    /// Class's private properties.
    private let database: DatabaseReference
}

// MARK: Class's public methods
extension MigrationLocationHistory {
    func execute() {
        guard let firebaseID = Auth.auth().currentUser?.uid else {
            return
        }

        let node = FireBaseTable.favoritePlace >>> .custom(identify: firebaseID)
        _ = database.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
        }
        .take(1)
        .subscribe(onNext: { snapshot in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                return
            }

            // Sorted list
            var list = dictionary.compactMap { try? $1.toData() }.compactMap { try? AddressHistory.toModel(from: $0, block: { $0.dateDecodingStrategy = .customDateFireBase }) }
                .sorted(by: { (item1, item2) -> Bool in
                    if item1.name != item2.name {
                        return item1.name < item2.name
                    } else {
                        return item1.timestamp > item2.timestamp
                    }
                })

            var results: [String: AddressHistory] = [:]
            list.forEach({ item in
                if var record = results[item.name] {
                    record.count += (item.count + 1)
                } else {
                    if item.count <= 0 {
                        var newItem = item
                        newItem.count = 1
                        results[item.name] = newItem
                    } else {
                        results[item.name] = item
                    }
                }
            })

            // Filtered list, we only accept any marker which has counter greater than or equal 5
            list = results.compactMap { $0.value }.filter { $0.count > 5 }
            guard list.count > 0, let realm = try? Realm() else {
                return
            }

            try? realm.write {
                list.forEach {
                    let markerHistory = MarkerHistory()
                    markerHistory.lastUsedTime = $0.timestamp
                    markerHistory.counter = $0.count
                    markerHistory.lat = $0.location.lat
                    markerHistory.lng = $0.location.lon

                    markerHistory.isOrigin = false
                    markerHistory.isVerifiedV2 = false

                    markerHistory.name = $0.name
                    markerHistory.lines.append($0.address)

                    realm.add(markerHistory)
                }

                let appState = realm.object(ofType: AppState.self, forPrimaryKey: 1)
                appState?.isMigratedToV530 = true
            }
        },
        onDisposed: {
//            FwiLog.debug("Event had been disposed.")
        })
    }
}

// MARK: Class's private methods
private extension MigrationLocationHistory {}

fileprivate struct AddressHistory: Decodable {
    let name: String
    let address: String
    var count: Int
    let timestamp: Date
    let location: Location
}

fileprivate struct Location: Decodable {
    let lat: Double
    let lon: Double
}
