//  File name   : GMSMap+Rx.swift
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

extension Reactive where Base: GMSMapView {
    public var delegate: DelegateProxy<GMSMapView, GMSMapViewDelegate> {
        return RxGMSMapDelegateProxy.proxy(for: base)
    }
    
    var locationChanged: Observable<CLLocationCoordinate2D> {
        return RxGMSMapDelegateProxy.proxy(for: base).locationSubject
    }
    
    var moving: Observable<Bool> {
        return RxGMSMapDelegateProxy.proxy(for: base).movingSubject
    }
}
