//  File name   : BookingRequestInteractor+TableFireBase.swift
//
//  Author      : Dung Vu
//  Created date: 1/18/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import Firebase
import FirebaseFirestore

// MARK: Codable
extension BookingRequestInteractor {
    var bookRef: UpdateDatabseRealtimeProtocol {
        let key = tripInfor.info.tripId
        return tripFirestoreRef.document(key)
    }
    
    var bookRefDb: DatabaseReference {
        let bookRef = dependency.firebaseDatabase
        return bookRef
    }
    
    var notifyRef: UpdateDatabseRealtimeProtocol {
        let key = tripInfor.info.tripId
        let tripNotifyCollection = Firestore.firestore().collection("TripNotify")
        let documentRef = tripNotifyCollection.document(key)
        return documentRef
    }
    
//    var notifyRef: DatabaseReference {
//        let key = tripInfor.info.tripId
//        let node = FireBaseTable.tripNotify >>> .custom(identify: key)
//        let notifyRef = dependency.firebaseDatabase.child(node.path)
//        return notifyRef
//    }
}
