//  File name   : BookingRequestInteractor+SendNotify.swift
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

// MARK: Codable
extension BookingRequestInteractor {
    // MARK: Send notify driver
    func sendNotifyToDriver() -> Observable<Void> {
        let infor = tripInfor.info
        let time = FireBaseTimeHelper.default.currentTime
        let notify = BookNotify.init(driverId: infor.driverFirebaseId,
                                     requestId: infor.clientFirebaseId,
                                     tripId: infor.tripId,
                                     timestamp: time)
        let notifyRef = self.notifyRef
        return Observable.create { (s) -> Disposable in
            do {
                let json = try notify.toJSON()
                notifyRef.setValue(json: json, completion: { (e) in
                    if let e = e {
                        s.onError(e)
                    } else {
                        s.onNext(())
                        s.onCompleted()
                    }
                })
            } catch {
                s.onError(error)
            }
            return Disposables.create()
        }
    }
    
    // MARK: Listener
    func listenNotifyRemove(from ref: DatabaseReference) -> Observable<Void> {
        let ref = ref
        return Observable.create({ (s) -> Disposable in
            let handler = ref.observe(.childRemoved, with: { (_) in
                s.onNext(())
                s.onCompleted()
            })
            return Disposables.create{
                ref.removeObserver(withHandle: handler)
            }
        })
    }
}
