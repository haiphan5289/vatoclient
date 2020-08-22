//  File name   : BookingRequestInteractor+LogicBook.swift
//
//  Author      : Dung Vu
//  Created date: 1/17/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import Firebase

extension BookingRequestInteractor {
    internal func findInformation(from driver: DriverSearch) -> Observable<Driver> {
        return self.dependency.firebaseDatabase.findDriver(from: driver.firebaseId).take(1)
    }
    
    internal func checkDriverHasTrip(from fireBaseId: String?) -> Observable<Void> {
        return self.dependency.firebaseDatabase.checkDriverHasTrip(from: fireBaseId).take(1).flatMap {[weak self] tripId -> Observable<Void> in
            // Check exist trip
            guard let tripId = tripId , !tripId.isEmpty else {
                return Observable.just(())
            }
            
            guard let wSelf = self else {
                return Observable.empty()
            }
            // recheck
            return wSelf.checkTripDriver(from: tripId)
        }
    }
    
    internal func checkTripDriver(from tripId: String) -> Observable<Void> {
        let node = FireBaseTable.trip >>> .custom(identify: tripId)
        let ref = dependency.firebaseDatabase.child(node.path)
        ref.keepSynced(true)
        return Observable.create({ (s) -> Disposable in
            ref.runTransactionBlock { [weak self](data) -> TransactionResult in
                guard let wSelf = self else {
                    s.onCompleted()
                    return TransactionResult.abort()
                }
                do {
                    try data.children.compactMap { $0 as? DataSnapshot }.forEach({ (snapshot) in
                        let trip = try FirebaseTrip.create(from: snapshot)
                        if wSelf.tripIsAvailable(from: trip) {
                            throw BookingError.driverInTrip
                        }
                    })
                    
                    s.onNext(())
                    s.onCompleted()
                } catch {
                    s.onError(error)
                }
                return TransactionResult.abort()
            }
            return Disposables.create()
        })
    }
    
    private func tripIsAvailable(from other: FirebaseTrip) -> Bool {
        var allCommand = other.command.map{ $0.value }
        guard allCommand.count > 0 else {
            return false
        }
        allCommand.sort(by: >)
        
        for c in allCommand {
            let status = c.status
            if status == .driverCancelInBook ||
                status == .driverCancelIntrip ||
                status == .driverDontEnoughMoney ||
                status == .driverMissing ||
                status == .clientTimeout ||
                status == .driverBusyInAnotherTrip ||
                status == .clientCancelInBook ||
                status == .clientCancelInBook ||
                status == .completed
            {
                return false
            }
        }
        let last = allCommand[0]
        let delta = Date().timeIntervalSince1970 * 1000 - last.time
        return !(delta > 30)
    }
    
    // MARK: - Generate key
    
    /// Generate trip key for firestore
    ///
    /// - Returns: document id
    /// - Throws: Not throw
    internal func makeTripKeyFromFirestore() throws -> String {
        let bookRef = tripFirestoreRef.document()
        return bookRef.documentID
    }
    
    /// Generate trip key for firebase
    ///
    /// - Returns: key trip
    /// - Throws: Error when can't create key
    internal func makeTripKey() throws -> String {
        let table = FireBaseTable.trip
        let ref = dependency.firebaseDatabase.child(table.node.path)
        guard let key = ref.childByAutoId().key, !key.isEmpty else {
            // Can't create key
            throw BookingError.cantCreateKey
        }
        return key
    }
    
    /// Generate trip code
    ///
    /// - Parameter key: key from firebase / firestore
    /// - Returns: code generate code
    /// - Throws: Error
    internal func makeTripCode(from key: String) throws -> String {
        guard let data = key.data(using: .utf8) else {
            // make data
            throw BookingError.cantEncodeKeyToData
        }
        let crc = CRC32(data: data).crc
        let tripCode = String.format(number: crc, base: 34)
        
        return tripCode.uppercased()
    }
    
    
    
    
}

