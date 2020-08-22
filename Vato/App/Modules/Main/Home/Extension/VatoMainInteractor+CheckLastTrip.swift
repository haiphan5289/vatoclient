//
//  VatoMainInteractor+CheckLastTrip.swift
//  Vato
//
//  Created by vato. on 10/30/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import FwiCoreRX
import RxSwift
import VatoNetwork
import FirebaseFirestore

extension VatoMainInteractor {
    
    func checkLastTrip() {
        currenttripAPIDisposable?.dispose()
        let e1 = BookingRequestCreateOrder.loadCurrentOrder().map { $0?.tripId }.filterNil()
        let e2 = self.getCurrentTrip()
        currenttripAPIDisposable = Observable.merge([e1, e2]).take(1).subscribe(onNext: { [weak self](tripId) in
            self?.checkLoadCurrentTrip(tripId: tripId)
        })
    }
    
    
    func getCurrentTrip() -> Observable<String> {
        return profileStream.user.take(1).flatMap { (user) -> Observable<String> in
            self.firebaseDatabase.findClientCurrentTrip(user: user)
        }
    }
    
    func checkLoadCurrentTrip(tripId: String?) {
        guard let tripId = tripId, !tripId.isEmpty else { return }
        let ref = Firestore.firestore().documentRef(collection: .trip,
                                                    storePath: .custom(path: tripId),
                                                    action: .read)
        ref.find(action: .get, source: .server)
            .filterNil()
            .bind(onNext: weakify({ (snapshot, wSelf) in
                guard snapshot.exists else { return }
                guard let tripInfoDic = snapshot.data() else { return }
                do {
                    let booking = try FCBooking(dictionary: tripInfoDic)
                    if booking.isTripComplete() {
                        BookingRequestCreateOrder.clearCurrentOrder()
                        wSelf.router?.showRatingView(book: booking)
                        return
                    }
                        
                    if booking.isAllowLoadTripLasted() {
                        wSelf.loadTrip(by: tripId, history: true)
                        return
                    }
                    BookingRequestCreateOrder.clearCurrentOrder()
                } catch {
                    BookingRequestCreateOrder.clearCurrentOrder()
                }
            })).disposeOnDeactivate(interactor: self)
    }
}
