//  File name   : BookingRequestInteractor+CheckDriverStatus.swift
//
//  Author      : Dung Vu
//  Created date: 1/22/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import Firebase

enum DriverOnlineType: Int {
    case unready = 0
    case ready = 10
    case busy = 20
}

fileprivate struct Time {
    static let delta: TimeInterval = 600000
}

extension BookingRequestInteractor {
    func checkDriverStatus(from driverSearch: DriverSearch) -> Observable<Void> {
        let driverSearch = driverSearch
        let radius = self.radius
        
        guard let startLocation = startCoordinate else {
            return Observable.error(BookingError.noStartCoordinate)
        }
        
        return dependency.firebaseDatabase.checkStatusDriver(from: driverSearch.firebaseId).flatMap { (status) -> Observable<Void> in
            var driverLo = (status.location?.location).orNil(.zero)
            // Try to capture from server
            if driverLo == .zero {
                driverLo = (driverSearch.location?.location).orNil(.zero)
            }
            
            guard !(driverLo == .zero) else {
                return Observable.error(BookingError.noDriverCoordinate)
            }
            
            let coordinateDriver = driverLo.coordinate
            let distance = startLocation.distance(to: coordinateDriver)
            
            let validRadius = distance < (radius * 1000)
            let online = status.status == DriverOnlineType.ready.rawValue
            let time = FireBaseTimeHelper.default.currentTime
            let lastOnline = status.lastOnline
            let deltaOnline = time - lastOnline
            // Check Time
            let validTimeOnline = lastOnline > 0 && (deltaOnline < Time.delta)
            guard validRadius, online, validTimeOnline else {
                return Observable.error(BookingError.driverNotValid)
            }
            
            return Observable.just(())
        }.debug("\(Config.prefixDebug) checkDriverStatus")
    }
}
