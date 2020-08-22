//  File name   : BookingConfirm+Intrip.swift
//
//  Author      : Dung Vu
//  Created date: 3/4/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import RIBs
import FirebaseFirestore

enum BookingConfirmHandlerType {
    case cancel
    case completed
    case clientCancel
    case newTrip
    case dismiss
}

final class BookingConfirmHandlerIntrip: NSObject, FCTripMapViewControllerDelegate {
    func newTrip() {
        state.onNext(.newTrip)
    }
    
    private (set) lazy var state: PublishSubject<BookingConfirmHandlerType> = PublishSubject()
    func onTripFailed() {
        state.onNext(.cancel)
    }
    
    func onTripCompleted() {
        state.onNext(.completed)
    }
    
    func onTripClientCancel() {
        state.onNext(.clientCancel)
    }
    
    func dissmissTripMap() {
        state.onNext(.dismiss)
    }

    deinit {
        printDebug("\(#function)")
    }
}

protocol BookingConfirmIntripProtocol {
    var handlerIntrip: BookingConfirmHandlerIntrip { get }
}

protocol FindTripProtocol {
    var firebaseDatabase: DatabaseReference { get }
}

extension FindTripProtocol {
    func findTripJSON(by tripId: String) -> Observable<JSON> {
        let documentRef = Firestore.firestore().documentRef(collection: .trip, storePath: .custom(path: tripId), action: .read)
        return  documentRef
            .find(action: .get, json: nil)
            .map { $0?.data() ?? [:] }
            .take(1)
            .observeOn(MainScheduler.asyncInstance)
    }
}


extension BookingConfirmRouter: BookingConfirmIntripProtocol, FindTripProtocol {
    var firebaseDatabase: DatabaseReference {
        return interactor.firebaseDatabase
    }
    
    func moveToIntrip(by tripId: String) {
        routeToIntrip(tripId: tripId)
//        self.loadTrip(by: tripId)
    }
    
    private func loadTrip(by tripId: String) {
        guard let i = interactor as? Interactor else {
            return
        }
        self.findTripJSON(by: tripId)
            .take(1)
            .subscribe(onNext: { [weak self] (tripInfo) in
                guard (tripInfo["info"] as? [String : Any]) != nil else {
                    return
                }
                
                self?.beginLastTrip(info: tripInfo)
                }, onError: { (error) in
                    let err = error as NSError
                    printDebug(err.localizedDescription)
        }).disposeOnDeactivate(interactor: i)
    }
    
    private func beginLastTrip(info: [String: Any]) {
        let controller = TripMapsViewController()
        controller.bookSnapshot = info
        controller.fromHistory = false
        controller.delegate = self.handlerIntrip
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        self.viewControllable.uiviewController.present(controller, animated: true, completion: nil)
    }
}
