//  File name   : ShoppingMainComponent+LocationPicker.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

/// The dependencies needed from the parent scope of ShoppingMain to provide for the LocationPicker scope.
// todo: Update ShoppingMainDependency protocol to inherit this protocol.
protocol ShoppingMainDependencyLocationPicker: Dependency {
    // todo: Declare dependencies needed from the parent scope of ShoppingMain to provide dependencies
    // for the LocationPicker scope.
}

extension ShoppingMainComponent: LocationPickerDependency {
    var authenticatedStream: AuthenticatedStream {
        return dependency.authenticated
    }
    

    // todo: Implement properties to provide for LocationPicker scope.
}


extension ShoppingMainRouter: BookingConfirmIntripProtocol, FindTripProtocol {
    var firebaseDatabase: DatabaseReference {
        return self.interactor.firebaseDatabase
    }
    
    func loadTrip(by tripId: String) {
        self.findTripJSON(by: tripId)
            .subscribe(onNext: { [weak self] (tripInfo) in
                guard (tripInfo["info"] as? [String : Any]) != nil else {
                    return
                }
                
                self?.beginLastTrip(info: tripInfo)
                }, onError: { (error) in
                    let err = error as NSError
                    printDebug(err.localizedDescription)
            }).disposeOnDeactivate(interactor: self.interactor)
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
