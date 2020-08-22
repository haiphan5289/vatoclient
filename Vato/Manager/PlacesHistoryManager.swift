//  File name   : PlacesHistoryManager.swift
//
//  Author      : Dung Vu
//  Created date: 11/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Realm
import RealmSwift
import FirebaseFirestore
import FirebaseAuth
import Firebase
import FwiCore
import FwiCoreRX
import RxSwift
import RxCocoa
import KeyPathKit
import VatoNetwork
import CoreLocation


// MARK: - Main
final class PlacesHistoryManager: SafeAccessProtocol, Weakifiable, ManageListenerProtocol {
    struct Configs {
        static let defaultRadius: Double = {
            return ConfigManager.shared.radiusDefault
        }()
        static let minDistance: Double = 15
        static let maxItem = 20
        static let interval: Int = 5
    }
    static let instance = PlacesHistoryManager()
    typealias E = PlacesHistoryModel
    
    /// Class's public properties.
    private (set) lazy var lock: NSRecursiveLock = NSRecursiveLock()
    var listenerManager: [Disposable] = []
    // Keep sync value
    private lazy var source: BehaviorRelay<[E]> = BehaviorRelay(value: [])
    private lazy var pointsOfInteresting: BehaviorRelay<[E]> = BehaviorRelay(value: [])
    private lazy var pointsOthers: BehaviorRelay<[E]> = BehaviorRelay(value: [])
    private (set) lazy var favoritePlaces: BehaviorRelay<[E]> = BehaviorRelay(value: [])
    
    private var realm: Realm? {
        do {
            let r = try Realm()
            return r
        } catch {
            defer {
                LogEventHelper.log(key: "Open_Realm_Database_Error", params: ["reason": error.localizedDescription])
            }
            #if DEBUG
                assert(false, error.localizedDescription)
            #endif
            return nil
        }
    }
    
    private var currentId: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    private var documentRef: DocumentReference?
    private var _config: ConfigPlacesHistoryModel?
    private var config: ConfigPlacesHistoryModel? {
        get {
            return excute { return _config }
        }
        set {
            excute { _config = newValue }
        }
    }
    private var readySyncCloud: Bool = false
    private lazy var disposeBag = DisposeBag()
    
    // MARK: - Init
    private init() { setupRX() }
    private func setupRX() {
        source.map { $0.filter(where: \.counter >= 2) }.bind(to: pointsOfInteresting).disposed(by: disposeBag)
        source.map { $0.filter(where: \.counter < 2) }.bind(to: pointsOthers).disposed(by: disposeBag)
        source.map { $0.filter(where: \.favoritePlaceID > 0 && \.active == true ) }.bind(to: favoritePlaces).disposed(by: disposeBag)
    }
    
    private func createConfig(_ firebaseId: String) {
        let new = ConfigPlacesHistoryModel()
        new.firebaseId = firebaseId
        do {
            try realm?.write {
                realm?.add(new)
            }
            config = new
        } catch {
            assert(false, error.localizedDescription)
        }
        migration()
    }
    
    private func handler(_ model: PlacesHistoryFireStore) throws {
        try realm?.write {
            let origin = model.origin ?? []
            if !origin.isEmpty {
                self.realm?.add(origin, update: .all)
            }
            
            let destination = model.destination ?? []
            if !destination.isEmpty {
                self.realm?.add(destination, update: .all)
            }
        }
        config?.update(lastTimeSync: Date().timeIntervalSince1970)
        loadDatabase()
    }
    
    private func cleanLocationIfNeeded() {
        let firebaseId = currentId
        let today = Int64(Date().timeIntervalSince1970)
        guard let result = realm?.objects(E.self).filter("firebaseId = '\(firebaseId)' AND counter == 0"), !result.isEmpty else {
            return
        }
        let items = result.filter { today - $0.lastUsedTime >= 172800 || $0.address?.isEmpty == true }
        guard !items.isEmpty else { return }
        do {
            try realm?.write {
                realm?.delete(items)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func cleanFavoriteIfNeeded() {
        let firebaseId = currentId
        let new: () -> ConfigAppLocal = {
            let n = ConfigAppLocal(use: firebaseId)
            ConfigAppLocal.addNew(item: n)
            return n
        }
        
        let object = realm?.object(ofType: ConfigAppLocal.self, forPrimaryKey: firebaseId) ?? new()
        object.updateValue { $0.version = AppConfig.default.appInfor?.version ?? "" }
        guard !object.cleanedFavorite else { return }
        
        let list = realm?.objects(PlacesHistoryModel.self).filter("firebaseId = '\(firebaseId)' AND favoritePlaceID > 0")
        if let old = list, !old.isEmpty {
            let realm = self.realm
            do {
                try realm?.write {
                    realm?.delete(old)
                }
            } catch {
                #if DEBUG
                assert(false, error.localizedDescription)
                #endif
            }
            
            object.updateValue {
                $0.cleanedFavorite = true
                $0.lastCleanup = Date().timeIntervalSince1970
            }
        } else {
            object.updateValue {
                $0.cleanedFavorite = true
                $0.lastCleanup = Date().timeIntervalSince1970
            }
        }
    }
    
    /// Class's constructors.
    func initialize() {
        cleanUpListener()
        realm?.refresh()
        let firebaseId = currentId
        cleanFavoriteIfNeeded()
        
        documentRef = Firestore.firestore().documentRef(collection: .placesHistory, storePath: .custom(path: firebaseId), action: .read)
            // Create
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                FavoritePlaceManager.shared.reload()
            }
        }
        
        guard let result = realm?.object(ofType: ConfigPlacesHistoryModel.self, forPrimaryKey: firebaseId) else {
            return createConfig(firebaseId)
        }
        config = result
        cleanLocationIfNeeded()
        migration()
    }
    /// Class's private properties.
}

// MARK: Class's public methods
extension PlacesHistoryManager {
    func addFavoritePlace(places: [PlaceModel]) {
        let realm = self.realm
        let firebaseId = currentId
        
        #if DEBUG
            print("============File Database=====")
            print(realm?.configuration.fileURL?.absoluteString ?? "")
            print("============End=====")
        #endif
        // remove old
        let list = realm?.objects(PlacesHistoryModel.self).filter("firebaseId = '\(firebaseId)' AND favoritePlaceID > 0")
        if let old = list, !old.isEmpty {
            for p in old {
                p.updateValue(changed: { $0.active = false })
            }
        }
        
        places.forEach { (item) in
            guard let id = item.id else { return }
            if let listObj = list?.filter("favoritePlaceID == \(id)"), !listObj.isEmpty {
                for obj in listObj {
                    obj.updateValue { (model) in
                        model.nameFavorite = item.name
                        model.address = item.address
                        model.descriptionFavorite = item.address
                        model.typeFavorite = item.typeId.rawValue
                        model.lat = item.coordinate.latitude
                        model.lon = item.coordinate.longitude
                        model.active = true
                        guard let placeId = item.placeId else { return }
                        model.placeId = placeId
                    }
                }
            } else {
                let origin = PlacesHistoryModel(from: item)
                origin.isOrigin = true
                
                let destination = PlacesHistoryModel(from: item)
                destination.isOrigin = false
                
                do {
                    try realm?.write({
                        realm?.add(origin, update: .all)
                        realm?.add(destination, update: .all)
                    })
                } catch {
                    #if DEBUG
                    assert(false, error.localizedDescription)
                    #endif
                }
            }
        }
    }
    
    @discardableResult
    func add(value: AddressProtocol, increase: Bool = true) -> AddressProtocol {
        let block: (AddressProtocol) -> AddressProtocol = {
            var new = $0
            // Update
            if let placeId = value.placeId {
                new.update(placeId: placeId)
            }
            
            guard increase else {
                return new
            }
            new.increaseCounter()
            return new
        }
        
        if value.isDatabaseLocal, let d = value as? E {
            d.updateValue(changed: { $0.lastUsedTime = Int64(Date().timeIntervalSince1970) * 1000 })
            return block(d)
        } else {
            // Check exist
            let origin = value.isOrigin
            let coor = value.coordinate
            let exist = search(latitude: coor.latitude, longitude: coor.longitude, maxDistance: 2, isOrigin: origin, bestAccurate: true)
            if let v = exist
            {
                return block(v)
            } else {
                let new = PlacesHistoryModel(from: value)
                if increase {
                    new.counter += 1
                }
                do {
                    try realm?.write {
                        self.realm?.add(new, update: .all)
                    }
                } catch {
                    assert(false, error.localizedDescription)
                }
                return new
            }
        }
    }
}

enum AlgorithmSearch: Int {
    case distance
    case counter
    
    func sort(by soure: [PlacesHistoryManager.E],
              coord: CLLocation,
              time: Int64,
              distance: Double ,
              validTime: Bool) -> [PlacesHistoryManager.E]
    {
        let today = Date()
        let result = soure.sorted { (l1, l2) -> Bool in
            let coord1 = CLLocation(latitude: l1.lat, longitude: l1.lon)
            let coord2 = CLLocation(latitude: l2.lat, longitude: l2.lon)
            let d1 = abs(coord1.distance(from: coord))
            let d2 = abs(coord2.distance(from: coord))
            
            switch self {
            case .counter:
                if l1.counter == l2.counter {
                    return d1 < d2
                } else {
                    return abs(d1 - d2) > 10  ? l1.counter > l2.counter : d1 < d2
                }
            case .distance:
                func validDistance() -> Bool {
                    let d11 = d1 < distance
                    let d21 = d2 < distance
                    switch (d11, d21) {
                    case (true, false):
                        return true
                    case (false, _):
                        return false
                    case (true, true):
                        if abs(d1 - d2) > 10 || l1.counter == l2.counter {
                            return d1 < d2
                        } else {
                            return l1.counter > l2.counter
                        }
                    }
                }
                
                if validTime {
                    let remain1 = Int64(today.timeIntervalSince1970) - l1.lastUsedTime
                    let remain2 = Int64(today.timeIntervalSince1970) - l2.lastUsedTime
                    let options = (remain1 < time, remain2 < time)
                    switch options {
                    case (true, false):
                        return true
                    case (false, true):
                        return false
                    default:
                        return validDistance()
                    }
                } else {
                    return validDistance()
                }
                
            }
        }
        
        return result
    }
}

// MARK: - Search
extension PlacesHistoryManager {
    func searchLatest(isOrigin: Bool = true) -> Observable<AddressProtocol?>{
        return source.take(1).map { $0.sorted(by: { (p1, p2) -> Bool in
            return p1.lastUsedTime > p2.lastUsedTime
        }).filter({ $0.isOrigin == isOrigin }).first(where: { $0.counter > 0 }) }
    }
    
    func searchListLastest(isOrigin: Bool = true) -> Observable<[AddressProtocol]>{
        return source.map { Array($0.sorted(by: { (p1, p2) -> Bool in
            return p1.lastUsedTime > p2.lastUsedTime
        }).filter({ $0.counter > 0 && $0.isOrigin == isOrigin }).prefix(20))}
    }
    
    func searchCounter(isOrigin: Bool = true) -> Observable<[AddressProtocol]> {
        return source.take(1).map { Array($0.sorted(by: { (p1, p2) -> Bool in
            return p1.counter > p2.counter
        }).filter({ $0.isOrigin == isOrigin })) }
    }
    
    private func search(using values:[E] ,
                        location: CLLocationCoordinate2D,
                        maxDistance distance: Double,
                        maxDay day: Int = 7,
                        algorithm: AlgorithmSearch,
                        isOrigin flag: Bool,
                        validTime: Bool) -> AddressProtocol?
    {
        let coord = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let circle = CLCircularRegion(center: location, radius: distance, identifier: "marker_history")
        
        let time = Int64(TimeInterval(day * 24 * 60 * 60))
        let coordinatesBound = values.filter {
            let coordinate = $0.coordinate
            return circle.contains(coordinate)
        }
        let histories = algorithm.sort(by: coordinatesBound, coord: coord, time: time, distance: distance, validTime: validTime)
        let result: AddressProtocol?
        if algorithm == .counter {
            result = histories.first(where: { (m) -> Bool in
                abs(m.coordinate.distance(to: location)) <= Configs.defaultRadius
            })
        } else {
            result = histories.first(where: { $0.isOrigin == flag })
        }
    
        return result
    }
    
    func search(latitude lat: Double,
                longitude lng: Double,
                maxDistance distance: Double = Configs.defaultRadius,
                maxDay day: Int = 7,
                isOrigin flag: Bool = true,
                bestAccurate: Bool = false,
                validTime: Bool = true) -> AddressProtocol?
    {
        guard distance > 0 else {
            return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        guard !bestAccurate else {
            return search(using: source.value, location: coordinate, maxDistance: distance, algorithm: .distance, isOrigin: flag, validTime: validTime)
        }
        
        if distance == Configs.minDistance || distance == Configs.defaultRadius {
            // favorite
            let s00 = favoritePlaces.value
            if let item = search(using: s00, location: coordinate, maxDistance: distance, maxDay: day, algorithm: .distance, isOrigin: flag, validTime: false) {
                return item
            }
            
            // find flow distance
            let s0 = source.value
            return search(using: s0, location: coordinate, maxDistance: distance, maxDay: day, algorithm: .distance, isOrigin: flag, validTime: validTime)
        }
        
        // Find in point interest
        let s1 = pointsOfInteresting.value
        if let result = search(using: s1, location: coordinate, maxDistance: Configs.defaultRadius, maxDay: day, algorithm: .counter, isOrigin: flag, validTime: validTime) {
            return result
        }
        let s2 = pointsOthers.value
        
        // Search normal
        return search(using: s2, location: coordinate, maxDistance: distance, maxDay: day, algorithm: .distance, isOrigin: flag, validTime: validTime)
    }
    
    func latestFiveOrigin() -> [AddressProtocol] {
        let values = source.value
        let histories = values
            .filter { $0.isOrigin }
            .sorted(by: { $0.lastUsedTime > $1.lastUsedTime })
            .prefix(5)
        
        return Array(histories)
    }
    
    func latestFiveDestination() -> [AddressProtocol] {
        let values = source.value
        let histories = values
            .filter { $0.isOrigin == false }
            .sorted(by: { $0.lastUsedTime > $1.lastUsedTime })
            .prefix(5)
        
        return Array(histories)
    }
    
    func search(name: String, location: MapModel.Location? = nil) -> AddressProtocol? {
        let values = source.value
        let keyword = name.lowercased().trim()
        if let lo = location {
            let history = values.first(where: { $0.lat == lo.lat && $0.lon == lo.lon })
            return history
        }
        else {
            let history = values.first(where: { $0.name?.lowercased() == keyword || $0.thoroughfare.lowercased() == keyword })
            return history
        }
    }
    
    public func searchMarker(with name: String, isOrigin: Bool) -> [AddressProtocol] {
        let values = source.value
        let keyword = name.lowercased().trim()
        let histories = values
            .filter { $0.isOrigin == isOrigin && (($0.name?.lowercased().contains(keyword) ?? false) || ($0.thoroughfare.lowercased().contains(keyword))) }
            .sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
        
        return Array(histories)
    }
}

// MARK: - Migrate
private extension PlacesHistoryManager {
    private func migration() {
        // Check can load from old
        defer {
            syncCloudToLocalIfNeeded()
        }
        guard config?.migration == false else {
            return
        }
        
        guard let items = realm?.objects(MarkerHistory.self).sorted(by: >), !items.isEmpty else {
            config?.update(migration: true)
            return
        }
        
        // Delete old
        do {
            try realm?.write {
                items.prefix(Configs.maxItem).forEach { (old) in
                    let new = PlacesHistoryModel(from: old)
                    realm?.add(new, update: .all)
                }
                realm?.delete(items)
                config?.migration = true
            }
        } catch {
            assert(false, error.localizedDescription)
        }
    }
}
// MARK: - Sync
private extension PlacesHistoryManager {
    private func syncCloudToLocalIfNeeded() {
        guard //config?.needSync == true,
            let ref = documentRef else {
            loadDatabase()
            return
        }
        
        let disposeAble = ref.find(action: .get, json: nil).debug("!!!!!===syncCloudToLocalIfNeeded===").subscribe(weakify({ (event, wSelf) in
            switch event {
            case .next(let res):
                guard res?.exists == true, let values = res?.data(), !values.isEmpty else {
                    wSelf.loadDatabase()
                    return
                }
                do {
                    //origin
                    //destination
                    var o: [JSON] = values.value("origin", defaultValue: [])
                    var d: [JSON] = values.value("destination", defaultValue: [])
                    
                    o = o.map { (old) -> JSON in
                        var new = old
                        new["isOrigin"] = true
                        new["firebaseId"] = Auth.auth().currentUser?.uid ?? ""
                        return new
                    }
                    
                    d = d.map { (old) -> JSON in
                        var new = old
                        new["isOrigin"] = false
                        new["firebaseId"] = Auth.auth().currentUser?.uid ?? ""
                        return new
                    }
                    
                    let origin = o.compactMap { try? PlacesHistoryModel.toModel(from: $0) }.filter(where: \.address != nil && \.name != nil)
                    let destination = d.compactMap { try? PlacesHistoryModel.toModel(from: $0) }.filter(where: \.address != nil && \.name != nil)
                    let new = PlacesHistoryFireStore(origin: origin, destination: destination)
                    
                    // sync
                    try wSelf.handler(new)
                    
                } catch {
                    wSelf.loadDatabase()
                    print(error.localizedDescription)
                }
            case .error(let e):
                print(e.localizedDescription)
            default:
                break
            }
        }))
        add(disposeAble)
    }
}

// MARK: Class's private methods
private extension PlacesHistoryManager {
    func loadDatabase() {
        readySyncCloud = true
        guard let realm = realm else {
            return
        }
        let firebaseId = currentId
        let result = realm.objects(E.self).filter("firebaseId = '\(firebaseId)' AND markerId != ''")
        let event = Observable<[E]>.create { [weak self](s) -> Disposable in
            let token = result.observe { (changes) in
                switch changes {
                case .update(let items, _, _, _):
                    s.onNext(Array(items))
                    guard items.first(where: { $0.counter > 0 }) != nil else { return }
                    self?.scheduleSyncToCloud()
                case .initial(let items):
                    s.onNext(Array(items))
                    guard items.first(where: { $0.counter > 0 }) != nil else { return }
                    self?.scheduleSyncToCloud()
                case .error(let e):
                    assert(false, e.localizedDescription)
                    s.onNext([])
                }
            }
            return Disposables.create {
                token.invalidate()
            }}
        
        let disposeAble = event.bind(onNext: weakify({ (list, wSelf) in
            wSelf.source.accept(list)
        }))
        add(disposeAble)
    }
    
    private func uploadToCloud() {
        guard let ref = self.documentRef else {
            return
        }
        var params = [String: Any]()
        let items = source.value.filter(where: \.counter > 0)
        let origin = items.filter(where: \.isOrigin).sorted(by: >).prefix(Configs.maxItem)
        let destination = items.filter(where: \.isOrigin == false).sorted(by: >).prefix(Configs.maxItem)
        let encoder = JSONEncoder()
        do {
            let d1 = try encoder.encode(Array(origin))
            let d2 = try encoder.encode(Array(destination))
            
            let p1 = try JSONSerialization.jsonObject(with: d1, options: [])
            let p2 = try JSONSerialization.jsonObject(with: d2, options: [])
            params["origin"] = p1
            params["destination"] = p2
            
            print(params)
        } catch {
            assert(false, error.localizedDescription)
        }
        
        let disposeAble = ref.find(action: .addField, json: params).subscribe(weakify({ (event, wSelf) in
            switch event {
            case .error(let e):
                #if DEBUG
                guard Auth.auth().currentUser != nil else {
                    return
                }
                assert(false, e.localizedDescription)
                #endif
            default:
                break
            }
        }))
        add(disposeAble)
    }
    
    private func scheduleSyncToCloud() {
        guard readySyncCloud else { return }
        let disposeAble = Observable<Int>.interval(.seconds(Configs.interval), scheduler: MainScheduler.asyncInstance).take(1).bind(onNext: weakify({ (_, wSelf) in
            wSelf.uploadToCloud()
        }))
        add(disposeAble)
    }
}
