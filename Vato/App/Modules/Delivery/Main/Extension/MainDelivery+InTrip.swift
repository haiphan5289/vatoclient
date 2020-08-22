//  File name   : MainDelivery+InTrip.swift
//
//  Author      : Dung Vu
//  Created date: 8/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import RIBs

extension MainDeliveryRouter: FindTripProtocol {
    var firebaseDatabase: DatabaseReference {
        return self.interactor.firebaseDatabase
    }
    
    func loadTrip(by tripId: String) {
        routeToIntrip(tripId: tripId)
//        self.findTripJSON(by: tripId)
//            .subscribe(onNext: { [weak self] (tripInfo) in
//                guard (tripInfo["info"] as? [String : Any]) != nil else {
//                    return
//                }
//
//                self?.beginLastTrip(info: tripInfo)
//                }, onError: { (error) in
//                    let err = error as NSError
//                    printDebug(err.localizedDescription)
//            }).disposeOnDeactivate(interactor: self.interactor)
    }
    
    private func beginLastTrip(info: [String: Any]) {
        let controller = TripMapsViewController()
        controller.bookSnapshot = info
        controller.fromHistory = false
        controller.fromDelivery = true
        controller.delegate = self.handlerIntrip
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .fullScreen
        
        self.viewControllable.uiviewController.present(controller, animated: true, completion: nil)
    }
}


