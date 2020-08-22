//
//  FireBase+Extension.swift
//  FaceCar
//
//  Created by Dung Vu on 11/8/18.
//  Copyright © 2018 Vato. All rights reserved.
//

import Foundation
import Firebase
import RxSwift

extension DatabaseReference {
    func findZone(with coordinate: CLLocationCoordinate2D) -> Observable<Zone> {
        // Check
        func trackContain(snap: DataSnapshot) -> Bool {
            guard let json = snap.value as? JSON,
                let polyline: String = json.value(for: "polyline", defaultValue: nil), !polyline.isEmpty,
                let path = GMSPath(fromEncodedPath: polyline) else {
                    return false
            }
            return GMSGeometryContainsLocation(coordinate, path, false)
        }
        let node = FireBaseTable.master >>> .zones >>> .custom(identify: "0") >>> .custom(identify: "cities")
        return self.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        }).flatMap({ snapshot -> Observable<DataSnapshot> in
            var childrens = snapshot.children.compactMap({ $0 as? DataSnapshot })
            
            // sort follow field sort
            childrens = childrens.sorted(by: { (dataSnapshot1, dataSnapshot2) -> Bool in
                guard let json1 = dataSnapshot1.value as? JSON,
                    let sort1: Int64 = json1.value(for: "sort", defaultValue: nil),
                    let json2 = dataSnapshot2.value as? JSON,
                    let sort2: Int64 = json2.value(for: "sort", defaultValue: nil) else {
                        return false
                }
                return sort1 > sort2
            })
            
            guard let result = childrens.first(where: { trackContain(snap: $0) }) else {
                return Observable.empty()
            }
            
            return Observable.just(result)
        }).map({ try Zone.create(from: $0) })
    }
    
    func allFare() -> Observable<[FareSetting]> {
        let node = FireBaseTable.master >>> .fareSetting
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.map { try $0.children.compactMap({ $0 as? DataSnapshot }).map { try FareSetting.create(from: $0) } }
    }
    
    func findFare(by zone: Zone) -> Observable<[FareSetting]> {
        return self.allFare().map { (allFare) -> [FareSetting] in
            let result = allFare.filter(by: zone.id)
            guard !result.isEmpty else {
                let listVN = allFare.filter(by: ZoneConstant.vn)
                return listVN
            }
            return result
        }
    }
    
    func findServices(by zone: Int) -> Observable<[Service]> {
        let node = FireBaseTable.master >>> .tableService >>> .custom(identify: "\(zone)")
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<[Service]> in
                let childrens = snapshot.children.compactMap({ $0 as? DataSnapshot })
                let services = try childrens.map({ try Service.create(from: $0) })
                return Observable.just(services)
        }
    }
    
    func findListFarePredicate() -> Observable<[FarePredicate]> {
        //FarePredicate
        let node = FireBaseTable.master >>> .farePredicate
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<[FarePredicate]> in
                let childrens = snapshot.children.compactMap({ $0 as? DataSnapshot })
                let farePredicates = try childrens.map({ try FarePredicate.create(from: $0, block: { $0.dateDecodingStrategy = .customDateFireBase }) })
                return Observable.just(farePredicates)
        }
    }
    
    func findListFareModifier() -> Observable<[FareModifier]> {
        //FarePredicate
        let node = FireBaseTable.master >>> .fareModifier
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<[FareModifier]> in
                let childrens = snapshot.children.compactMap({ $0 as? DataSnapshot })
                let fareModifiers = try childrens.map({ try FareModifier.create(from: $0) })
                return Observable.just(fareModifiers)
        }
    }
    
    func findBookAddPrice() -> Observable<TipConfig> {
        //FarePredicate
        let node = FireBaseTable.master >>> .appConfigure
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<TipConfig> in
                let config = try TipConfig.create(from: snapshot)
                return Observable.just(config)
        }
    }
    
    func findAppConfigure() -> Observable<AppConfigure> {
        //FarePredicate
        let node = FireBaseTable.master >>> .appConfigure
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<AppConfigure> in
                let config = try AppConfigure.create(from: snapshot)
                return Observable.just(config)
        }
    }
}

// MARK: - Driver
extension DatabaseReference {
    func findDriver(from firebaseId: String?) -> Observable<Driver> {
        guard let firebaseId = firebaseId, !firebaseId.isEmpty else {
            return Observable.error(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Recheck id"]))
        }
        
        let node = FireBaseTable.driver >>> .custom(identify: firebaseId)
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<Driver> in
                let config = try Driver.create(from: snapshot)
                return Observable.just(config)
        }
    }
    
    func checkDriverHasTrip(from firebaseId: String?) -> Observable<String?>{
        guard let firebaseId = firebaseId, !firebaseId.isEmpty else {
            return Observable.error(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Recheck id"]))
        }
        
        let node = FireBaseTable.driverTrip >>> .custom(identify: firebaseId)
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<String?> in
                return Observable.just(snapshot.value as? String)
        }
    }
    
    func checkStatusDriver(from firebaseId: String?) -> Observable<DriverOnlineStatus> {
        guard let firebaseId = firebaseId, !firebaseId.isEmpty
            else {
                return Observable.error(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey: "Recheck id"]))
        }
        
        let groupId = firebaseId.javaHash() % 10
        let key = "\(groupId)"
        let node = FireBaseTable.driverOnline >>> .custom(identify: key) >>> .custom(identify: firebaseId)
        
        return self.find(by: node, type: .value, using: {
            $0.keepSynced(true)
            return $0
        }).map{
            try DriverOnlineStatus.create(from: $0)
        }.take(1)
    }
}

// MARK: - User Data
extension DatabaseReference {
    
    func updateFirebaseClient(for client: ClientProtocol, with firebaseID: String) {
        let node = FireBaseTable.client >>> .custom(identify: firebaseID)
        self.child(node.path).updateChildValues(client.updateFirebaseClient) { (err, _) in
            guard let err = err else {
                return
            }
            printError(err: err)
        }
    }
    
    func updateFirebaseUser(for user: UserProtocol) {
        let node = FireBaseTable.user >>> .custom(identify: user.firebaseID)
        self.child(node.path).updateChildValues(user.updateFirebaseUser) { (err, _) in
            guard let err = err else {
                return
            }
            printError(err: err)
        }
    }

    func findUser(firebaseId: String) -> Observable<UserInfo> {
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<UserInfo> in
                let user = try UserInfo.create(from: snapshot)
                return Observable.just(user)
        }
    }
    
    func findClient(firebaseId: String) -> Observable<Client> {
        let node = FireBaseTable.client >>> .custom(identify: firebaseId)
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<Client> in
                let user = try Client.create(from: snapshot)
                return Observable.just(user)
        }
    }
    
    func updatePaymentMethod(method: PaymentMethod, firebaseId: String) {
        let node = FireBaseTable.client >>> .custom(identify: firebaseId)
        let data = ["paymentMethod": method.rawValue]
        let ref = self.child(node.path)
        ref.updateChildValues(data)
    }
    
    func updateBalance(cash: Double, coin: Double, firebaseId: String) {
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        let data = ["cash": cash, "coin": coin]
        let ref = self.child(node.path)
        ref.updateChildValues(data)
    }
    
    func updateEmail(email: String, firebaseId: String) {
        let node = FireBaseTable.user >>> .custom(identify: firebaseId)
        let data = ["email": email]
        let ref = self.child(node.path)
        ref.updateChildValues(data)
    }
    
    func updateDeviceToken(deviceToken: String, firebaseId: String) {
        let node = FireBaseTable.client >>> .custom(identify: firebaseId)
        var data = ["deviceToken": deviceToken]

        if
            let info = Bundle.main.infoDictionary,
            let version = info["CFBundleShortVersionString"] as? String
        {
            data["version"] = version
        }

        let ref = self.child(node.path)
        ref.updateChildValues(data)
    }
    
    func updateRegisterUser(from user: Vato.User) -> Observable<Void> {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            let json = (try JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
            guard var v = json, !v.keys.isEmpty else {
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey : "Not have json"])
            }
            v["cash"] = 0
            v["coin"] = 0
            let nodeUser = FireBaseTable.user >>> .custom(identify: user.firebaseID)
            let ref = self.child(nodeUser.path)
            
            return Observable.create({ (s) -> Disposable in
                ref.updateChildValues(v, withCompletionBlock: { (e, _) in
                    if let e = e {
                        s.onError(e)
                    } else {
                        s.onNext(())
                        s.onCompleted()
                    }
                })
                return Disposables.create()
            }).flatMap({ [unowned self]  in
                self.updateClient(use: user, from: v)
            })
        } catch {
            return Observable.error(error)
        }
    }
    
    func updateClient(use user: Vato.User, from json: [String: Any]) -> Observable<Void> {
        var json = json
        json.removeValue(forKey: "user")
        
        let nodeClient = FireBaseTable.client >>> .custom(identify: user.firebaseID)
        let ref = self.child(nodeClient.path)
        
        return Observable.create({ (s) -> Disposable in
            ref.updateChildValues(json, withCompletionBlock: { (e, _) in
                if let e = e {
                    s.onError(e)
                } else {
                    s.onNext(())
                    s.onCompleted()
                }
            })
            return Disposables.create()
        })
    }
}

// MARK: - TRIP
extension DatabaseReference {
    
    @objc func writeCurrentRatingTrip(clientFirebaseId: String?, info: FCBookInfo?) {
        guard let clientFirebaseId = clientFirebaseId,
            clientFirebaseId.isEmpty == false,
            let info = info,
            let json = info.toDictionary() else { return }
        let node = FireBaseTable.client >>> .custom(identify: clientFirebaseId) >>> .custom(identify: "CurrentRating")
        
        
        let bookRef = self.child(node.path)
        bookRef.setValue(json)
    }
    
    @objc func removeClientCurrentRating(clientFirebaseId: String?) {
        guard let clientFirebaseId = clientFirebaseId,
            clientFirebaseId.isEmpty == false else { return }
        let node = FireBaseTable.client >>> .custom(identify: clientFirebaseId) >>> .custom(identify: "CurrentRating")
        let bookRef = self.child(node.path)
        bookRef.removeValue()
    }
    
    @objc func writeClientCurrentTrip(clientFirebaseId: String?, tripId: String?) {
        guard let clientFirebaseId = clientFirebaseId,
            let tripId = tripId,
            clientFirebaseId.isEmpty == false ,
            tripId.isEmpty == false  else { return }
        let node = FireBaseTable.clientCurrentTrip >>> .custom(identify: clientFirebaseId)
        
        let bookRef = self.child(node.path)
        bookRef.setValue(tripId) { (e, _) in
            assert(e == nil, e?.localizedDescription ?? "")
        }
    }
    
    @objc func removeClientCurrentTrip(clientFirebaseId: String?) {
        guard let clientFirebaseId = clientFirebaseId,
            clientFirebaseId.isEmpty == false else { return }
        let node = FireBaseTable.clientCurrentTrip >>> .custom(identify: clientFirebaseId)
        
        let bookRef = self.child(node.path)
        bookRef.setValue(nil) { (e, _) in
            guard let e = e else { return }
            assert(false, e.localizedDescription)
        }
    }
    
    func findTrip(tripId: String) -> Observable<[String: Any]> {
        let node = FireBaseTable.trip >>> .custom(identify: tripId)
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.flatMap { (snapshot) -> Observable<[String: Any]> in
                guard let data = snapshot.value as? [String: Any] else {
                    return Observable.empty()
                }
                
                return Observable.just(data)
        }
    }
    
    func findClientCurrentTrip(user: UserInfo) -> Observable<String> {
        let node = FireBaseTable.clientCurrentTrip >>> .custom(identify: user.firebaseId)
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.take(1)
            .flatMap { (snapshot) -> Observable<String> in
                guard let data = snapshot.value as? String else {
//                    return Observable.empty()
                    return Observable.error(NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: [NSLocalizedDescriptionKey: "Not Found"]))
                }
                return Observable.just(data)
        }
    }
    
    func findClientCurrentRating(firebaseId: String) -> Observable<FCBookInfo> {
        let node = FireBaseTable.client >>> .custom(identify: firebaseId) >>> .custom(identify: "CurrentRating")
        return self.find(by: node, type: .value) {
            $0.keepSynced(true)
            return $0
            }.take(1)
            .flatMap { (snapshot) -> Observable<FCBookInfo> in
                guard let data = snapshot.value as? FCBookInfo else {
                    return Observable.empty()
                }
                return Observable.just(data)
        }
    }
}
