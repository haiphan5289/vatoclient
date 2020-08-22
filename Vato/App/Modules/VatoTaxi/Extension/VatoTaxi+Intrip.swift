//  File name   : VatoTaxi+Intrip.swift
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

enum VatoTaxiHandlerType {
    case cancel
    case completed
    case clientCancel
    case newTrip
    case dismiss
}

final class VatoTaxiHandlerIntrip: NSObject, FCTripMapViewControllerDelegate {
    func newTrip() {
        state.onNext(.newTrip)
    }
    
    private (set) lazy var state: PublishSubject<VatoTaxiHandlerType> = PublishSubject()
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

protocol VatoTaxiIntripProtocol {
    var handlerIntrip: VatoTaxiHandlerIntrip { get }
}
extension VatoTaxiRouter: VatoTaxiIntripProtocol, FindTripProtocol {
    var firebaseDatabase: DatabaseReference {
        return self.interactor.firebaseDatabase
    }
    
    func moveToIntrip(by tripId: String) {
//        self.loadTrip(by: tripId)
        routeToIntrip(tripId: tripId)
    }
    
    private func loadTrip(by tripId: String) {
        guard let i = interactor as? Interactor else {
            return
        }
        self.findTripJSON(by: tripId)
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

