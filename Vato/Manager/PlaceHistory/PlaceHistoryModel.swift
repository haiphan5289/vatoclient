//  File name   : PlaceHistoryModel.swift
//
//  Author      : Dung Vu
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import CoreLocation
import KeyPathKit
import Realm
import RealmSwift

// MARK: - Update database protocol
protocol UpdateDatabaseLocalProtocol {}
extension UpdateDatabaseLocalProtocol where Self: Object {
    func updateValue(changed: (Self) -> ()) {
        do {
            try realm?.write { changed(self) }
        } catch {
            #if DEBUG
                assert(false, error.localizedDescription)
            #endif
        }
    }
}

extension Object: UpdateDatabaseLocalProtocol {}

// MARK: - Model
public class PlacesHistoryModel: Object, Codable, AddressProtocol, Comparable {
    public static func < (lhs: PlacesHistoryModel, rhs: PlacesHistoryModel) -> Bool {
        if lhs.lastUsedTime != rhs.lastUsedTime {
            return lhs.lastUsedTime < rhs.lastUsedTime
        } else {
            return lhs.counter < rhs.counter
        }
    }
    
    var thoroughfare: String {
        return subLocality
    }
    
    var streetNumber: String {
        return ""
    }
    
    var streetName: String {
        return ""
    }
    
    var locality: String {
        return ""
    }
    
    var subLocality: String {
        return address?.orEmpty(name ?? "") ?? name ?? ""
    }
    
    var administrativeArea: String {
        return ""
    }
    
    var postalCode: String {
        return ""
    }
    
    var country: String {
        return ""
    }
    
    var lines: [String] {
        return [subLocality]
    }
    
    var isDatabaseLocal: Bool {
        return true
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        set {
            self.lat = newValue.latitude
            self.lon = newValue.longitude
        }
    }
    
    var distance: Double?

    @objc dynamic var markerId = ""
    @objc dynamic var placeId: String?
    @objc dynamic var lat: Double = 0
    @objc dynamic var lon: Double = 0
    @objc dynamic var name: String?
    @objc dynamic var address: String?
    @objc dynamic var counter: Int = 0
    @objc dynamic var firebaseId: String = ""
    @objc dynamic var zoneId: Int = 0
    @objc dynamic var lastUsedTime: Int64 = 0
    @objc dynamic var isOrigin: Bool = false
    
    @objc dynamic var favoritePlaceID: Int64 = 0
    @objc dynamic var nameFavorite: String?
    @objc dynamic var descriptionFavorite: String?
    @objc dynamic var typeFavorite: Int = -1
    @objc dynamic var active: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case markerId
        case placeId
        case lat
        case lon
        case name
        case address
        case counter
        case firebaseId
        case zoneId
        case lastUsedTime
        case isOrigin
        case favoritePlaceID
        case active
        case typeFavorite
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var mId = try values.decode(String.self, forKey: .markerId)
        if mId.isEmpty {
            let id = Date().timeIntervalSince1970
            let userId = UserManager.instance.userId ?? 0
            mId = "\(userId)_\(id)"
        }
        markerId = mId
        placeId = try values.decodeIfPresent(String.self, forKey: .placeId)
        lat = try values.decode(Double.self, forKey: .lat)
        lon = try values.decode(Double.self, forKey: .lon)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        counter = try values.decode(Int.self, forKey: .counter)
        firebaseId = try values.decode(String.self, forKey: .firebaseId)
        zoneId = try values.decode(Int.self, forKey: .zoneId)
        lastUsedTime = try values.decode(Int64.self, forKey: .lastUsedTime)
        isOrigin = try values.decode(Bool.self, forKey: .isOrigin)
        
        if let fId = try values.decodeIfPresent(Int64.self, forKey: .favoritePlaceID) {
            favoritePlaceID = fId
        }
        
        if let active = try values.decodeIfPresent(Bool.self, forKey: .active) {
            self.active = active
        }
        
        if let typeFavorite = try values.decodeIfPresent(Int.self, forKey: .typeFavorite) {
            self.typeFavorite = typeFavorite
        }
    }

    public override static func primaryKey() -> String? {
        return "markerId"
    }
        
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlacesHistoryModel  else {
            return false
        }
        
        return abs(self.coordinate.distance(to: other.coordinate)) <= 1000
    }
    
    convenience init(from history: MarkerHistory) {
        self.init()
        let id = Date().timeIntervalSince1970
        let userId = UserManager.instance.userId ?? 0
        markerId = "\(userId)_\(id)"
        lat = history.coordinate.latitude
        lon = history.coordinate.longitude
        name = history.name
        address = history.subLocality
        counter = history.counter
        isOrigin = history.isOrigin
        firebaseId = Auth.auth().currentUser?.uid ?? ""
        placeId = history.address.placeId
        favoritePlaceID = history.favoritePlaceID
        nameFavorite = history.nameFavorite
        descriptionFavorite = history.descriptionFavorite
        lastUsedTime = Int64(history.lastUsedTime.timeIntervalSince1970 * 1000)
    }
    
    convenience init(from favoritePlace: PlaceModel) {
        self.init()
        let id = Date().timeIntervalSince1970
        let userId = UserManager.instance.userId ?? 0
        markerId = "\(userId)_\(id)"
        lat = favoritePlace.coordinate.latitude
        lon = favoritePlace.coordinate.longitude
        isOrigin = true
        counter = 1
        placeId = favoritePlace.placeId
        firebaseId = Auth.auth().currentUser?.uid ?? ""
        favoritePlaceID = favoritePlace.id.orNil(0)
        nameFavorite = favoritePlace.name
        descriptionFavorite = favoritePlace.address
        lastUsedTime = Int64(favoritePlace.lastUse)
        typeFavorite = favoritePlace.typeId.rawValue
        address = favoritePlace.address
    }
    
    convenience init(from address: AddressProtocol) {
        self.init()
        let id = Date().timeIntervalSince1970
        let userId = UserManager.instance.userId ?? 0
        name = address.name
        markerId = "\(userId)_\(id)"
        lat = address.coordinate.latitude
        lon = address.coordinate.longitude
        zoneId = address.zoneId
        lastUsedTime = Int64(Date().timeIntervalSince1970) * 1000
        counter = address.counter
        firebaseId = Auth.auth().currentUser?.uid ?? ""
        isOrigin = address.isOrigin
        placeId = address.placeId
        favoritePlaceID = address.favoritePlaceID
        nameFavorite = address.nameFavorite
        descriptionFavorite = address.descriptionFavorite
        active = address.active
        self.address = address.subLocality
    }
    
    required init() {
        super.init()
    }
    
    func increaseCounter() {
        updateValue { $0.counter += 1; $0.lastUsedTime = Int64(Date().timeIntervalSince1970) * 1000 }
    }
    
    func update(zoneId: Int) {
        updateValue { $0.zoneId = zoneId }
    }
    
    func update(isOrigin: Bool) {
        updateValue { $0.isOrigin = isOrigin }
    }
    
    func update(placeId: String?) {
        updateValue { $0.placeId = placeId }
    }
    
    func update(subLocality: String?) {
        guard let s = subLocality, !s.isEmpty  else {
            return
        }
        updateValue { $0.address = s }
    }
    
    func update(coordinate: CLLocationCoordinate2D?) {
        updateValue { $0.coordinate = coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0) }
    }
    
    func update(name: String?) {
        updateValue { $0.name = name }
    }
}

// MARK: - Config
@objcMembers
final class ConfigAppLocal: Object {
    dynamic var firebaseId = ""
    dynamic var version: String = AppConfig.default.appInfor?.version ?? ""
    dynamic var cleanedFavorite: Bool = false
    dynamic var lastCleanup: TimeInterval = Date().timeIntervalSince1970

    public override static func primaryKey() -> String? {
        return "firebaseId"
    }
    
    convenience init(use firebaseId: String) {
        self.init()
        self.firebaseId = firebaseId
    }
}

protocol GenerateModelDatabaseProtocol {}
extension GenerateModelDatabaseProtocol where Self: Object {
    static func addNew(item: Self) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(item, update: .all)
            }
            
        } catch {
            #if DEBUG
            assert(false, error.localizedDescription)
            #endif
        }
    }
}

extension Object: GenerateModelDatabaseProtocol {}

public class ConfigPlacesHistoryModel: Object {
    @objc dynamic var firebaseId = ""
    @objc dynamic var syncedCloud: Bool = false
    @objc dynamic var migration: Bool = false
    @objc dynamic var lastSyncedTime: TimeInterval = 0
    
    var needSync: Bool {
        let delta = abs(lastSyncedTime - Date().timeIntervalSince1970)
        return delta > 300
    }
    
    public override static func primaryKey() -> String? {
        return "firebaseId"
    }
    
    func update(lastTimeSync: TimeInterval) {
        let v = lastTimeSync
        do {
            try realm?.write {
                self.lastSyncedTime = v
                self.syncedCloud = true
            }
        } catch {
            assert(false, error.localizedDescription)
        }
    }
    
    func update(migration: Bool) {
        do {
            try realm?.write {
                self.migration = migration
            }
        } catch {
            assert(false, error.localizedDescription)
        }
    }
}

// MARK: - Cloud model
struct PlacesHistoryFireStore: Codable {
    var origin: [PlacesHistoryModel]?
    var destination: [PlacesHistoryModel]?
}



