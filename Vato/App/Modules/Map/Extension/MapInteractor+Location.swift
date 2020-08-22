//  File name   : MapInteractor+Location.swift
//
//  Author      : Dung Vu
//  Created date: 2/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa
import VatoNetwork

/*
 Adjust logic location UI:
 
 Note : ListenerLocation = Event listen update location from location service (system)
 1> User is not turn on location service:
 - Create ListenerLocation update location to time when user run location service,
 stop listen when user move on map or location updated.
 2> Location still not coordinate from current yet (hardware update slow):
 - Create ListenerLocation update location, stop listen when user move on map or location updated.
 3> In Home:
 // Make check again some case location update again
 - Create ListenerLocation update location, stop listen when user move on map or location updated.
 4> Camera map update:
 - Only update after had information location.
 5> Search name:
 - Only search if coordinate different from default (Tập Đoàn Phương Trang).
 */

protocol MapLocationProtocol {
    var stopListenUpdateLocation: PublishSubject<Void> { get }
}

extension MapInteractor {
    // Begin show location (become active)
    func beginLoadLocation() {
        // Observe only when
        defaultLocation()
//        defer {
//            listenerLocation()
//        }
//
//        guard let location = VatoLocationManager.shared.location else {
//            defaultLocation()
//            return
//        }
//        lookupAddress(for: location, distance: PlacesHistoryManager.Configs.defaultRadius)
    }
    
    // Use default
    func defaultLocation() {
        let marker = Config.defaultMarker
        let s =  PlacesHistoryManager.instance.search(latitude: marker.lat, longitude: marker.lng, maxDistance: PlacesHistoryManager.Configs.defaultRadius, maxDay: 100, isOrigin: true, bestAccurate: false, validTime: false)
        mutableBooking.updateBooking(originAddress: s ?? marker.address)
    }
    
    // Create listen
    func listenerLocation() {
        NotificationCenter.default.rx.notification(Notification.Name.locationUpdated)
            .takeUntil(self.stopListenUpdateLocation)
            .debug("Map listenerLocation")
            .map { (notification) -> CLLocation in
                guard let location = notification.object as? CLLocation else {
                    throw NSError(domain: "vn.futa.client.Vato", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid location type."])
                }
                return location
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] location in
                guard let wSelf = self else { return }
                wSelf.presenter.moveCamera(to: location.coordinate)
                wSelf.lookupAddress(for: location, distance: PlacesHistoryManager.Configs.defaultRadius)
                },  onError:
            { [weak self] _ in
                guard let wSelf = self else { return }
                wSelf.router?.presentAlert(title: "Không tìm thấy địa điểm", message: "Địa điểm của bạn không được tìm thấy. Bạn vui lòng điều chỉnh vị trí ghim tới địa chỉ chính xác.", cancelAction: "Điều chỉnh vị trí ghim")
            }).disposeOnDeactivate(interactor: self)
    }
    
    
    func lookupAddress(for location: CLLocation?, distance: Double) {
        guard let location = location else {
            return
        }
        disposeLocation?.dispose()
        let coordinate = location.coordinate
        var isUpdate = false
        disposeLocation = self.lookupAddress(for: coordinate, maxDistanceHistory: distance, isOrigin: true)
            .subscribe(onNext: { [weak self] (result) in
                isUpdate = true
                self?.mutableBooking.updateBooking(originAddress: result)
                }, onError: { e in
                    print(e.localizedDescription)
            }, onCompleted: { [weak self] in
                guard !isUpdate else {
                    return
                }
                self?.findFromGoogle(for: location)
            })
    }
    
    private func findFromGoogle(for location: CLLocation?) {
        guard let location = location else {
            return
        }
        disposeLocation?.dispose()
        let coordinate = location.coordinate
        disposeLocation = mutableAuthenticated.googleAPI.take(1).flatMap {
            GoogleAPI.reverseGeocode(with: coordinate, googleAPIKey: $0)
        }.subscribe(onNext: { [weak self] (result) in
            guard let result = result else { return }
            let markerHistory = MarkerHistory(with: result)
            self?.mutableBooking.updateBooking(originAddress: markerHistory.address)
            }, onError: { e in
                print(e.localizedDescription)
        })
    }
}
