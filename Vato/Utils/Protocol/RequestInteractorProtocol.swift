//  File name   : RequestInteractorProtocol.swift
//
//  Author      : Dung Vu
//  Created date: 11/21/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import VatoNetwork
import RIBs

protocol RequestInteractorProtocol: AnyObject {
    var token: Observable<String> { get }
}

extension RequestInteractorProtocol {
    var token: Observable<String> {
        return FirebaseTokenHelper.instance.eToken.filterNil().take(1)
    }
    
    func request<E>(map: @escaping (String) -> Observable<E>) -> Observable<E> {
        return token.flatMap(map)
    }
}

protocol LocationRequestProtocol: RequestInteractorProtocol {
    func lookupAddress(for location: CLLocationCoordinate2D, maxDistanceHistory: Double, isOrigin: Bool) -> Observable<AddressProtocol>
}

extension LocationRequestProtocol {
    func lookupAddress(for location: CLLocationCoordinate2D, maxDistanceHistory: Double, isOrigin: Bool) -> Observable<AddressProtocol> {
        let markerHistory = PlacesHistoryManager.instance.search(latitude: location.latitude, longitude: location.longitude, maxDistance: maxDistanceHistory, isOrigin: isOrigin)
        if let m = markerHistory,
            let p = m.placeId, !p.isEmpty
        {
            return Observable.just(m)
        } else {
            return request(map: { MapAPI.geocoding(authToken: $0, lat: location.latitude, lng: location.longitude) })
                .timeout(.seconds(30), scheduler: MainScheduler.asyncInstance)
                .map { v -> AddressProtocol in
                    if var markerHistory = markerHistory {
                        markerHistory.update(placeId: v.placeId)
                        return markerHistory
                    } else {
                        var new = MarkerHistory(with: v).address
                        new.update(isOrigin: isOrigin)
                        return PlacesHistoryManager.instance.add(value: new, increase: false)
                    }

                }
                .catchErrorJustReturn(MapInteractor.Config.defaultMarker.address)
        }
    }
    
    func validate(address: AddressProtocol) -> Observable<AddressProtocol> {
        if let p = address.placeId, !p.isEmpty {
            return Observable.just(address)
        } else {
            return lookupAddress(for: address.coordinate, maxDistanceHistory: PlacesHistoryManager.Configs.minDistance, isOrigin: address.isOrigin)
        }
    }
    
}

extension LocationRequestProtocol where Self: Interactor {
    func updateAddress(model: AddressProtocol, update: @escaping (AddressProtocol) -> ()) {
        self.validate(address: model)
            .bind(onNext:update)
            .disposeOnDeactivate(interactor: self)
    }
}
