//  File name   : BookingRequestInteractor+Radius.swift
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

extension BookingRequestInteractor {
    func findAppConfig() {
        dependency.firebaseDatabase.findAppConfigure().take(1).observeOn(SerialDispatchQueueScheduler(qos: .background)).bind { [weak self] in
            guard let wSelf = self else {
                return
            }
            wSelf.appConfig = $0
            
        }.disposeOnDeactivate(interactor: self)
    }
    
    func findRadius() {
        let currentModelBook = dependency.currentModelBook
        guard let distance = currentModelBook.service?.fare?.trip?.distance.value, distance > 0 else {
            return
        }
        let zoneId = currentModelBook.zone?.id ?? -1
        guard let radius = self.appConfig?.radius(from: zoneId, distance: distance) else {
            return
        }
        self.radius = radius
    }
}
