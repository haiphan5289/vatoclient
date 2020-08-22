//  File name   : RxGMSMapDelegateProxy.swift
//
//  Author      : Dung Vu
//  Created date: 7/15/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import GoogleMaps
import RxSwift
import RxCocoa

extension GMSMapView: HasDelegate {
    public typealias Delegate = GMSMapViewDelegate
}

final class RxGMSMapDelegateProxy: DelegateProxy<GMSMapView, GMSMapViewDelegate>, DelegateProxyType, GMSMapViewDelegate {
    
    let locationSubject = ReplaySubject<CLLocationCoordinate2D>.create(bufferSize: 1)
    let movingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    
    private var isAnimation: Bool = false
    
    init(mapView: GMSMapView) {
        super.init(parentObject: mapView, delegateProxy: RxGMSMapDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register(make: (RxGMSMapDelegateProxy.init(mapView:)))
    }
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        _forwardToDelegate?.mapView?(mapView, willMove: gesture)
        defer { isAnimation = !gesture }

        guard gesture else {
            return
        }
        movingSubject.on(.next(true))
    }

    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        _forwardToDelegate?.mapView(mapView, idleAt: position)
        locationSubject.on(.next(position.target))
        defer { isAnimation = false }
        guard !isAnimation else {
            return
        }
        movingSubject.on(.next(false))
    }
    
    deinit {
        locationSubject.onCompleted()
        movingSubject.onCompleted()
    }
}


