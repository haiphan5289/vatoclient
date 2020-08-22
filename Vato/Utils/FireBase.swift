//  File name   : FireBase.swift
//
//  Author      : Dung Vu
//  Created date: 9/26/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import Firebase
import Foundation
import RxSwift
import FirebaseFirestore

//#define TABLE_DRIVER_TRIP       @"DriverCurrentTrip"
//#define TABLE_BOOK_HIS          @"BookingHistoryV2"
//#define TABLE_FAVORITE          @"FavoriteV2"
//#define TABLE_CAR_TYPE          @"VivuServices"
//#define TABLE_CAR_GROUP         @"CarGroups"
//#define TABLE_FARE_PREDICATE    @"FarePredicate"
//#define TABLE_FARE_MANIFEST     @"Manifest"
//#define TABLE_APP_SETTINGS      @"SettingsV2"
//#define TABLE_DRIVER_ONLINE     @"DriverOnline"
//#define TABLE_PLACE_HIS         @"FavoritePlace"
//#define TABLE_PUNISHMENT        @"Punishments"
//#define TABLE_EVALUTION         @"CustomerReport/Rating"
//#define TABLE_CHATS             @"Chats"
//#define TABLE_SHIP_SERVICE      @"ShipService"
//#define TABLE_CAMPAIGNS         @"Campaigns"

// MARK: -- Create model from firebase
protocol ModelFromFireBaseProtocol {}
extension ModelFromFireBaseProtocol where Self: Decodable {
    static func create(from snapshot: DataSnapshot, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        let json = (snapshot.value as? [String: Any]) ?? [:]
        let data = try json.toData()
        return try self.toModel(from: data, block: block)
    }
    
    static func create(from snapshot: DocumentSnapshot, block: ((JSONDecoder) -> Void)? = nil) throws -> Self {
        let json = snapshot.data() ?? [:]
        let data = try json.toData()
        return try self.toModel(from: data, block: block)
    }
}

// MARK: -- Enum table
enum FireBaseTable {
    case master
    case appConfigure
    case googleApiKeys
    case zones
    case partners
    case driver
    case user
    case client
    case cars
    case trip
    case tripNotify
    case fareSetting
    case tableService
    case farePredicate
    case fareModifier
    case favoritePlace
    case favorite
    // Book
    case driverOnline
    case driverTrip
    case clientCurrentTrip
    case chats
    
    case custom(identify: String)
    
    var name: String {
        switch self {
        case .master:
            return "Masters"
        case .appConfigure:
            return "AppConfigure"
        case .googleApiKeys:
            return "google_api_keys"
        case .zones:
            return "Zones"
        case .partners:
            return "Partners"
        case .driver:
            return "Driver"
        case .user:
            return "User"
        case .client:
            return "Client"
        case .cars:
            return "Cars"
        case .trip:
            return "Trip"
        case .tripNotify:
            return "TripNotify"
        case .fareSetting:
            return "FareSettingV2"
        case .tableService:
            return "ClientServicesV3"
        case .farePredicate:
            return "FarePredicateV2"
        case .fareModifier:
            return "FareModifier"
        case .favoritePlace:
            return "FavoritePlace"
        case .custom(let identify):
            return identify
        case .favorite:
            return "FavoriteV2"
        case .driverOnline:
            return "DriverOnline"
        case .driverTrip:
            return "DriverCurrentTrip"
        case .clientCurrentTrip:
            return "ClientCurrentTrip"
        case .chats:
            return "Chats"
        }
    }
    
    var node: NodeTable {
        return NodeTable(currentTable: self, path: self.name)
    }
}
// MARK: -- Extension
extension DatabaseReference {
    typealias DataBase = DatabaseReference
    typealias Query = DatabaseQuery
    func find(by node: NodeTable,
              type: DataEventType,
              using block: ((DataBase) -> Query)? = nil) -> Observable<DataSnapshot> {
        let ref = self.child(node.path)
        let query: Query = block?(ref) ?? self
        return Observable.create({ (s) -> Disposable in
            let handler = query.observe(type, with: { snap in
                s.onNext(snap)
            }, withCancel: {
                s.onError($0)
            })
            return Disposables.create {
                ref.removeObserver(withHandle: handler)
            }
        })
    }
}
// MARK: -- Firestore
enum FirestoreTable {
    case trip
    case placesHistory
    case configData
    case client
    case paymentMethods
    case bannerConfig
    case suggestServices
    case theme
    case buslineConfig
    case quickSupportCategory
    case quickSupport
    case quickSupportComment
    case supply
    case custom(id: String)
    
    var name: String {
        switch self {
        case .trip:
            return "Trip"
        case .placesHistory:
            return "PlacesHistory"
        case .configData:
            return "ConfigData"
        case .client:
            return "Client"
        case .paymentMethods:
            return "PaymentMethods"
        case .bannerConfig:
            return "BannerConfig"
        case .suggestServices:
            return "SuggestServices"
        case .buslineConfig:
            return "BuslineConfig"
        case .theme:
            return "Theme"
        case .quickSupportCategory:
            return "SupportQuestionCategory"
        case .quickSupport:
            return "SupportQuestion"
        case .quickSupportComment:
            return "Comment"
        case .supply:
            return "Supply"
        case .custom(let id):
            return id
        }
    }
    
    static func path(with items: [FirestoreTable]) -> String{
        return items.map(\.name).joined(separator: "/")
    }
}

enum FirestorePath {
    case custom(path: String)
    case tetConfig
    
    var path: String {
        switch self {
        case .custom(let p):
            return p
        case .tetConfig:
            return "TetConfig"
        }
    }
}

enum FirestoreAction {
    case read
    case addModel(json: [String: Any])
}

extension Firestore {
    func collection(collection: FirestoreTable...) -> CollectionReference {
        let path = FirestoreTable.path(with: collection)
        return self.collection(path)
    }
    
    func documentRef(collection: FirestoreTable...,
                storePath: FirestorePath,
                action: FirestoreAction) -> DocumentReference
    {
        
        let collection = self.collection(FirestoreTable.path(with: collection))
        switch action {
        case .addModel(let value):
            let newRef = collection.addDocument(data: value) { (e) in
                if let e = e {
                    print(e.localizedDescription)
                }
            }
            return newRef
        case .read:
            let ref = collection.document(storePath.path)
            return ref
        }
    }
}

protocol QueryDocumentsFirestoreProtocol {
    associatedtype E
    func documents() -> Observable<E>
}

extension CollectionReference: QueryDocumentsFirestoreProtocol {
    typealias E = [DocumentSnapshot]?
    func documents() -> Observable<[DocumentSnapshot]?> {
        return Observable.create({ (s) -> Disposable in
            self.getDocuments(completion: { (snapshot, e) in
                if let error = e {
                    return s.onError(error)
                }
                
                s.onNext(snapshot?.documents)
                s.onCompleted()
            })
            
            return Disposables.create()
        })
    }
}

extension Query {
    func getDocuments() -> Observable<[DocumentSnapshot]?> {
        return Observable.create({ (s) -> Disposable in
            self.getDocuments(completion: { (snapshot, e) in
                if let error = e {
                    return s.onError(error)
                }
                
                s.onNext(snapshot?.documents)
                s.onCompleted()
            })
            
            return Disposables.create()
        })
    }
    
    typealias E = [DocumentSnapshot]?
}

// oberverble
extension CollectionReference {
    func listenFeedback() -> Observable<[QueryDocumentSnapshot]> {
        return Observable.create({ (s) -> Disposable in
            var id: ListenerRegistration?
            let handler: (QuerySnapshot?, Error?) -> () = { querySnapshot, error in
                if let e = error {
                    s.onError(e)
                } else {
                    var r: [QueryDocumentSnapshot] = []
                    querySnapshot?.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            r.addOptional(diff.document)
                        }
                    }
                    s.onNext(r)
                }
            }
            
            id = self.whereField("createdAt", isGreaterThan: 0).limit(to: 100).addSnapshotListener(handler)
            return Disposables.create {
                guard let handler = id else {
                    return
                }
                handler.remove()
            }
        })
    }
}

extension DocumentReference: QueryDocumentsFirestoreProtocol {
    typealias E = DocumentSnapshot?
    func documents() -> Observable<DocumentSnapshot?> {
        return Observable.create({ (s) -> Disposable in
            self.getDocument(completion: { (snapshot, e) in
                if let error = e {
                    return s.onError(error)
                }
                
                s.onNext(snapshot)
                s.onCompleted()
            })
            
            return Disposables.create()
        })
    }
}

extension DocumentSnapshot {
    func decode<T: Decodable>(to type: T.Type, block: ((JSONDecoder) -> Void)? = nil) throws -> T {
        let json = data() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let model = try T.toModel(from: data, block: block)
        return model
    }
}

@objc
enum DocumentFirestoreAction: Int {
    /* listen change */
    case listen
    /* get data */
    case get
    /* delete */
    case delete
    /* write override */
    case addData
    /* write append not override */
    case addField
    /* update only field exists , else , error */
    case update
}

extension DocumentReference {
    @objc
    func findObjC(action: DocumentFirestoreAction, json: [String: Any]?, completion: ((DocumentSnapshot?, Error?) -> ())?) {
        _ = self.find(action: action, json: json).subscribe(onNext: { (d) in
            completion?(d, nil)
        }, onError: { (e) in
            completion?(nil, e)
        })
    }
    
    func find(action: DocumentFirestoreAction, json: [String: Any]? = nil, source: FirestoreSource = .default) -> Observable<DocumentSnapshot?> {
        return Observable.create({ (s) -> Disposable in
            var id: ListenerRegistration?
            let handler: (DocumentSnapshot?, Error?) -> () = { snapshot, error in
                if let e = error {
                    s.onError(e)
                } else {
                    s.onNext(snapshot)
                    guard action != .listen else {
                        return
                    }
                    s.onCompleted()
                }
            }
            switch action {
            case .listen:
                id = self.addSnapshotListener(includeMetadataChanges: false, listener: handler)
            case .get:
                self.getDocument(source: source, completion: handler)
            case .delete:
                self.delete(completion: { (e) in
                    handler(nil, e)
                })
            case .addData:
                self.setData(json ?? [:], completion: { (e) in
                    handler(nil, e)
                })
            case .addField:
                self.setData(json ?? [:], merge: true, completion: { (e) in
                    handler(nil, e)
                })
            case .update:
                self.updateData(json ?? [:], completion: { (e) in
                    handler(nil, e)
                })
            }
            return Disposables.create {
                guard let handler = id else {
                    return
                }
                handler.remove()
            }
        })
    }
    
    func findTripSever(json: [String: Any]?, loop: Int = 0) -> Observable<DocumentSnapshot?> {
        return Observable.create({ (s) -> Disposable in
            let handler: (DocumentSnapshot?, Error?) -> () = { snapshot, error in
                if let e = error {
                    s.onError(e)
                } else {
                    if snapshot?.metadata.isFromCache == true {
                        let e = NSError(domain: NSURLErrorDomain, code: -1999, userInfo: nil)
                        s.onError(e)
                        return
                    }
                    if snapshot?.metadata.hasPendingWrites == true {
                        let e = NSError(domain: NSURLErrorDomain, code: -1999, userInfo: nil)
                        s.onError(e)
                        return
                    }
                    s.onNext(snapshot)
                    s.onCompleted()
                }
            }
            self.getDocument(source: .server, completion: handler)
            return Disposables.create {
            }
        }).catchError({ (e) in
            if loop >= 3 {
                return Observable.error(e)
            }
            if (e as NSError).code == -1999 {
               return self.findTripSever(json: nil, loop: (loop + 1))
            } else {
               return Observable.error(e)
            }
        })
    }
    
}


extension CollectionReference {
    
    func listenNotificationTaxi() -> Observable<DocumentChangeModel> {
        return listenChanges().map { DocumentChangeModel(values: $0) }
    }
}

protocol QueryListenerProtocol {
    func listenChanges() -> Observable<CollectionValuesChanges>
}


extension Query: QueryListenerProtocol {
    func listenChanges() -> Observable<CollectionValuesChanges> {
        return Observable.create({ (s) -> Disposable in
            var id: ListenerRegistration?
            let handler: (QuerySnapshot?, Error?) -> () = { querySnapshot, error in
                var result = CollectionValuesChanges()
                if let e = error {
                    s.onError(e)
                } else {
                    querySnapshot?.documentChanges.forEach { diff in
                        var current = result[diff.type] ?? []
                        current.addOptional(diff.document)
                        result[diff.type] = current
                    }
                    s.onNext(result)
                }
            }
            id = self.addSnapshotListener(handler)
            return Disposables.create {
                guard let handler = id else {
                    return
                }
                handler.remove()
            }
        })
    }
}
