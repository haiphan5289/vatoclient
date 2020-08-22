//  File name   : BookingRequestInteractor+WriteInformation.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import Firebase
import FirebaseFirestore


extension BookingRequestInteractor {
    func writeInformationBookToDatabase(from json: JSON) -> Observable<Void> {
        let bookRef = self.bookRef
        return Observable.create({ (s) -> Disposable in
            bookRef.setValue(json: json) { (e) in
                if let e = e {
                    s.onError(e)
                } else {
                    s.onNext(())
                    s.onCompleted()
                }
            }
            return Disposables.create()
        })
    }
    
    
    func updateBook(by command: FirebaseTrip.BookCommand) -> Observable<Void> {
        /*
         defer {
         self.updateTracking(by: command)
         }
         */
        let ref = self.bookRef
        return Observable.create({ (s) -> Disposable in
            do {
                let json = try command.toJSON()
                let key = command.status.key
                
                // tracking
                let keyTracking = "\(command.status.rawValue)"
                let round = UInt64(FireBaseTimeHelper.default.currentTime)
                let tracking = FirebaseTrip.Tracking()
                tracking.command = command.status
                let date = Date()
                tracking.clientLocalTime = date.string(from: "yyyyMMdd HH:mm:ss")
                tracking.clientTimestamp = TimeInterval(round)
                let coordinate = self.currentLocation.coordinate
                tracking.clientLocation = Coordinate.init(from: coordinate.latitude, lng: coordinate.longitude)
                
                let jsonTracking = try tracking.toJSON()
                
                //command
                let dic: JSON = ["command": [key: json],
                                 "last_command": key,
                                 "tracking": [keyTracking: jsonTracking]]
                ref.update(json: dic, completion: { (error) in
                    if let error = error {
                        s.onError(error)
                    } else {
                        s.onNext(())
                        s.onCompleted()
                    }
                })
            } catch {
                s.onError(error)
            }
            return Disposables.create()
        })
    }
    
}

// MARK: Tracking
extension BookingRequestInteractor {
    func updateTracking(by command: FirebaseTrip.BookCommand) {
        // Ignore
        let bookRef = self.bookRef
        let status = command.status
        /*
        guard !(status == .clientTimeout ||
            status == .driverDontEnoughMoney ||
            status == .driverBusyInAnotherTrip) else {
            return
        }
        */
        let round = UInt64(FireBaseTimeHelper.default.currentTime)
        let key = "\(status.rawValue)"
        let tracking = FirebaseTrip.Tracking()
        tracking.command = status
        let date = Date()
        tracking.clientLocalTime = date.string(from: "yyyyMMdd HH:mm:ss")
        tracking.clientTimestamp = TimeInterval(round)
        let coordinate = currentLocation.coordinate
        tracking.clientLocation = Coordinate.init(from: coordinate.latitude, lng: coordinate.longitude)
        
        do {
            let json = try tracking.toJSON()
            bookRef.update(path: "tracking/\(key)", json: json)
        } catch {
            print("\(Config.prefixDebug) Tracking error: \(error)")
        }
    }
}

protocol UpdateDatabseRealtimeProtocol {
    func update(path: String, json: JSON)
    func update(path: String, json: JSON, completion: @escaping (Error?) -> ())
    func setValue(json: JSON, completion: @escaping (Error?) -> ())
    func listener(property: String) -> Observable<JSON?>
    
    func update(json: JSON, completion: @escaping (Error?) -> ())
}

extension DatabaseReference: UpdateDatabseRealtimeProtocol {
    func update(json: JSON, completion: @escaping (Error?) -> ()) {
        json.forEach { dic in
            if let value = dic.value as? [AnyHashable : Any] {
                self.child(dic.key).updateChildValues(value)
            }
        }
        completion(nil)
    }
    
    func listener(property: String) -> Observable<JSON?> {
        let table = FireBaseTable.custom(identify: property)
        return self.find(by: table.node, type: .childAdded){
            $0.keepSynced(true)
            return $0
        }.map { $0.value as? JSON }
    }
    
    func update(path: String, json: JSON, completion: @escaping (Error?) -> ()) {
        self.child(path).updateChildValues(json) { (e, _) in
            completion(e)
        }
    }
    
    func setValue(json: JSON, completion: @escaping (Error?) -> ()) {
        self.setValue(json) { (e, _) in
            completion(e)
        }
    }
    
    func update(path: String, json: JSON) {
        self.child(path).updateChildValues(json)
    }
}

extension DocumentReference: UpdateDatabseRealtimeProtocol {
    func update(json: JSON, completion: @escaping (Error?) -> ()) {
        self.setData(json, merge: true, completion: completion)
    }
    
    func listener(property: String) -> Observable<JSON?> {
        return self.find(action: .listen, json: nil).map { (snapshot) -> JSON? in
            let data = snapshot?.data()
            guard !property.isEmpty else {
                return data
            }
            
            guard let json: JSON = data?.value(for: property, defaultValue: nil) else {
                return nil
            }
            return json
        }
    }
    
    func update(path: String, json: JSON, completion: @escaping (Error?) -> ()) {
        var result = JSON()
        if path.isEmpty {
            result = json
        } else {
            let components = path.components(separatedBy: "/").reversed()
            components.enumerated().forEach { (v) in
                if v.offset == 0 {
                    result = [v.element : json]
                } else {
                    result = [v.element : result]
                }
            }
        }
        self.setData(result, merge: true, completion: completion)
    }
    
    func setValue(json: JSON, completion: @escaping (Error?) -> ()) {
        self.setData(json, completion: completion)
    }
    
    func update(path: String, json: JSON) {
        var result = JSON()
        if path.isEmpty {
            result = json
        } else {
            let components = path.components(separatedBy: "/").reversed()
            components.enumerated().forEach { (v) in
                if v.offset == 0 {
                    result = [v.element : json]
                } else {
                    result = [v.element : result]
                }
            }
        }
        self.setData(result, merge: true)
    }
}


