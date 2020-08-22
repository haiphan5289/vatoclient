//  File name   : BookingRequestInteractor+MakeBookInformation.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase
import RxSwift

// MARK: - Send book to database
extension BookingRequestInteractor {
    func book() -> Observable<Void> {
        self.inBookTrip = true
        return createBookInformation().flatMap({ [weak self] json -> Observable<Void>  in
            guard let wSelf = self else {
                return Observable.empty()
            }
            
            return wSelf.writeInformationBookToDatabase(from: json)
        })
    }
    
    func bookByFirestore() -> Observable<Void> {
        self.inBookTrip = true
        return createBookInformationByFirestore().flatMap({ [weak self] json -> Observable<Void>  in
            guard let wSelf = self else {
                return Observable.empty()
            }

            return wSelf.writeInformationBookToDatabase(from: json)
        })
    }
    
}
// MARK: - Create book information
extension BookingRequestInteractor {
    
    /// Generate book by firebase
    ///
    /// - Returns: event JSON
    func createBookInformation() -> Observable<JSON>  {
        do {
            let key = try makeTripKey()
            tripInfor.info.tripId = key
            tripInfor.info.tripCode = try makeTripCode(from: key)
            
            // Make Command
            let status = TripDetailStatus.clientCreateBook
            let time = FireBaseTimeHelper.default.currentTime
            let command = FirebaseTrip.BookCommand.init(status: status, time: time)
            tripInfor.command[status.key] = command
            
            // Convert to json
            let json = try tripInfor.toJSON()
            return Observable.just(json)
        } catch {
            return Observable.error(error)
        }
    }
    /// Generate book by firestore
    ///
    /// - Returns: event JSON
    func createBookInformationByFirestore() -> Observable<JSON>  {
        do {
            let key = try makeTripKeyFromFirestore()
            tripInfor.info.tripId = key
            tripInfor.info.tripCode = try makeTripCode(from: key)
            
            // Make Command
            let status = TripDetailStatus.clientCreateBook
            let time = FireBaseTimeHelper.default.currentTime
            let command = FirebaseTrip.BookCommand.init(status: status, time: time)
            tripInfor.command[status.key] = command
            tripInfor.last_command = "\(status.key)"
            // Convert to json
            let json = try tripInfor.toJSON()
            return Observable.just(json)
        } catch {
            return Observable.error(error)
        }
    }
    
}

