//  File name   : LocationStream.swift
//
//  Author      : Vato
//  Created date: 11/7/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RxSwift
import Foundation
import CoreLocation

// MARK: Immutable stream
protocol LocationStream: class {
    var authorizationStatus: Observable<CLAuthorizationStatus> { get }
    var location: Observable<CLLocation> { get }
}

// MARK: Mutable stream
protocol MutableLocationStream: LocationStream {
    func stop()
    func start()

    func userDefaultLocation(lat: Double, lng: Double)
}

// MARK: Default stream implementation
final class LocationStreamImpl: NSObject, MutableLocationStream {
    /// Class's public properties.
    var authorizationStatus: Observable<CLAuthorizationStatus> {
        return statusSubject.asObservable()
    }

    var location: Observable<CLLocation> {
        return locationSubject.asObservable()
    }

    /// Class's constructor.
    override init() {
        super.init()

        let currentStatus = CLLocationManager.authorizationStatus()
        statusSubject.onNext(currentStatus)

        buffer.buffer(timeSpan: 2, count: 10, scheduler: SerialDispatchQueueScheduler(qos: .background))
            .filter { $0.count > 0 }
            .map { values -> CLLocation? in
                return values.sorted(by: { $0.horizontalAccuracy < $1.horizontalAccuracy }).first
            }
            .filterNil()
            .bind(to: locationSubject)
            .disposed(by: disposeBag)
    }

    /// Class's destructor.
    deinit {
        startDisposable?.dispose()
        startDisposable = nil
    }

    func stop() {
        locationManager.stopUpdatingLocation()
    }

    func start() {
        startDisposable?.dispose()
        startDisposable = nil

        startDisposable = statusSubject.take(1)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (currentStatus) in
                switch currentStatus {
                case .notDetermined:
                    self?.locationManager.requestWhenInUseAuthorization()

                case .authorizedAlways, .authorizedWhenInUse:
                    self?.locationManager.startUpdatingLocation()

                default:
                    self?.locationManager.stopUpdatingLocation()
                }
            })
    }

    func userDefaultLocation(lat: Double, lng: Double) {
        let defaultLocation = CLLocation(latitude: lat, longitude: lng)
        locationSubject.onNext(defaultLocation)
    }

    /// Class's private properties.
    private let statusSubject = ReplaySubject<CLAuthorizationStatus>.create(bufferSize: 1)
    private let locationSubject = ReplaySubject<CLLocation>.create(bufferSize: 1)

    private var startDisposable: Disposable?
    private lazy var disposeBag = DisposeBag()
    private lazy var buffer = PublishSubject<CLLocation>()

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()

        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        manager.delegate = self
        return manager
    }()
}

// MARK: CLLocationManagerDelegate's members
extension LocationStreamImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        statusSubject.onNext(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        buffer.onNext(newLocation)
    }
}
