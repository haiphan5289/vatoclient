//
//  BookingConfirmInteractor+CheckLastTrip.swift
//  Vato
//
//  Created by vato. on 10/30/19.
//  Copyright © 2019 Vato. All rights reserved.
//

import Foundation
import RxSwift
import VatoNetwork
import FirebaseFirestore
extension VatoTaxiInteractor {
    
    func checkLastTrip() -> Observable<String> {
        return Observable.create({ (s) -> Disposable in
            self.getCurrentTrip()
                .take(1)
                .subscribe(onNext: { (tripId) in
                    if tripId.isEmpty == true {
                        s.onError(NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: [NSLocalizedDescriptionKey: "Not Found"]))
                        return
                    }
                    
                    self.checkLoadCurrentTrip(tripId: tripId)
                        .take(1)
                        .subscribe(onNext: { (tripId) in
                            if tripId.isEmpty == true {
                                s.onError(NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: [NSLocalizedDescriptionKey: "Not Found"]))
                            } else {
                                s.onNext(tripId)
                            }
                        }, onError: { (e) in
                            s.onError(e)
                        }).disposeOnDeactivate(interactor: self)
                }, onError: { (e) in
                    s.onError(e)
                }).disposeOnDeactivate(interactor: self)
            return Disposables.create()
        })
    }
    
    func getCurrentTrip() -> Observable<String> {
        return profileStream.user.take(1).flatMap { (user) -> Observable<String> in
            return self.firebaseDatabase.findClientCurrentTrip(user: user).take(1)
        }
    }
    
    func checkLoadCurrentTrip(tripId: String) -> Observable<String> {
        return Observable.create({ (s) -> Disposable in
            self.findTripJSONSever(by: tripId)
                .take(1)
                .subscribe(onNext: { (tripInfo) in
                    
                    var book: FCBooking?
                    do {
                        book = try FCBooking(dictionary: tripInfo)
                        if let commandDic = tripInfo["command"] as? [String : Any] {
                            var arrCommand = [FCBookCommand]()
                            commandDic.values.forEach({ (d) in
                                if let d = d as? [AnyHashable : Any] {
                                    do {
                                        let command = try FCBookCommand(dictionary: d)
                                        arrCommand.append(command)
                                    } catch {
                                    }
                                }
                            })
                            book?.command = arrCommand.sorted(by: { (c1, c2) -> Bool in
                                return c1.status < c2.status
                            })
                        }
                    } catch {}
                    
                    guard let _ = tripInfo["info"] as? [String : Any],
                        let _book = book,
                        _book.isAllowLoadTripLasted() else {
                            s.onError(NSError(domain: NSURLErrorDomain, code: NSURLErrorResourceUnavailable, userInfo: [NSLocalizedDescriptionKey: "Not Found"]))
                            return
                    }
                    
                    s.onNext(tripId)
                }, onError: { (error) in
                    s.onError(error)
                }).disposeOnDeactivate(interactor: self)
            return Disposables.create()
        })
    }
    
    private func findTripJSONSever(by tripId: String) -> Observable<JSON> {
        let documentRef = Firestore.firestore().documentRef(collection: .trip, storePath: .custom(path: tripId), action: .read)
        return  documentRef
            .findTripSever(json: nil)
            .map { $0?.data() ?? [:] }
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
    }
    
}
