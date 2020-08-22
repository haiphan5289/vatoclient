//  File name   : PickLocationInteractor.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import Alamofire
import RealmSwift
import RIBs
import RxSwift
import VatoNetwork

protocol PickLocationRouting: Routing {
    func cleanupViews()
    func enableConfirmButton()
}

protocol PickLocationListener: class {
    func beginConfirmBooking()
}

final class PickLocationInteractor: Interactor, PickLocationInteractable, LocationRequestProtocol {
    /// Class's public properties.
    weak var router: PickLocationRouting?
    weak var listener: PickLocationListener?

    var address: Observable<String> {
        return addressSubject.asObservable()
    }

    var location: Observable<CLLocationCoordinate2D> {
        return locationSubject.asObservable()
    }

    var token: Observable<String> {
        return authenticated.firebaseAuthToken.take(1)
    }
    
    /// Class's constructor
    init(mutableBooking: MutableBookingStream,
         authenticated: AuthenticatedStream,
         bookingState: BookingState,
         googleAPIKey: String)
    {
        self.mutableBooking = mutableBooking
        self.authenticated = authenticated
        self.bookingState = bookingState
        self.googleAPIKey = googleAPIKey
        switch bookingState {
        case .pickLocation(let locationType), .editPickLocation(let locationType):
            self.locationType = locationType

        default:
            self.locationType = .origin
        }
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRX()
    }

    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()

        // todo: Pause any business logic.
    }

    /// Class's private's properties
    private let mutableBooking: MutableBookingStream
    private let authenticated: AuthenticatedStream
    private let bookingState: BookingState
    private let locationType: LocationType
    private let googleAPIKey: String

    private let addressSubject = ReplaySubject<String>.create(bufferSize: 1)
    private let locationSubject = ReplaySubject<CLLocationCoordinate2D>.create(bufferSize: 1)

    private var searchDisposable: Disposable?

    private var markerHistory: AddressProtocol? {
        didSet {
            router?.enableConfirmButton()
        }
    }
}

extension PickLocationInteractor {
    func backToSearchLocation() {
        switch bookingState {
        case .pickLocation(let locationType):
            mutableBooking.changeMode(mode: .searchLocation(suggestMode: locationType))

        case .editPickLocation(let locationType):
            mutableBooking.changeMode(mode: .editSearchLocation(suggestMode: locationType))

        case .editQuickBookingPickLocation:
            mutableBooking.changeMode(mode: .editQuickBookingSearchLocation)
        case .homeMapSearch(suggestMode: .origin):
            mutableBooking.changeMode(mode: .home)

        default:
            break
        }
    }

    func handlerConfirmPickLocation() {
        guard let history = markerHistory else {
            return
        }

        // Update booking stream
        if locationType == .origin {
            mutableBooking.updateBooking(originAddress: history)
        } else {
            mutableBooking.updateBooking(destinationAddress1: history)
        }

        // Route to next action
        switch bookingState {
        case .pickLocation(let locationType):
            if locationType == .origin {
                mutableBooking.changeMode(mode: .searchLocation(suggestMode: .destination1))
            } else {
                listener?.beginConfirmBooking()
            }

        case .editPickLocation:
            listener?.beginConfirmBooking()

        case .editQuickBookingPickLocation:
            mutableBooking.changeMode(mode: .quickBookingConfirm)
            
        case .homeMapSearch(suggestMode: .origin):
            mutableBooking.changeMode(mode: .home)

        default:
            break
        }
    }

    func lookupCurrentAddress() {
        guard let currentLocation = VatoLocationManager.shared.location else {
            return
        }
        lookupAddress(for: currentLocation.coordinate)
    }

    func lookupAddress(for coordinate: CLLocationCoordinate2D) {
        searchDisposable?.dispose()
        let isOrigin = locationType == .origin
        searchDisposable = self.lookupAddress(for: coordinate,
                                              maxDistanceHistory: PlacesHistoryManager.Configs.minDistance,
                                              isOrigin: isOrigin)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (result) in
                self?.markerHistory = result
                
                self?.locationSubject.on(.next(result.coordinate))
                self?.addressSubject.on(.next(result.subLocality))
            })
    }
}

// MARK: Class's private methods
private extension PickLocationInteractor {
    private func setupRX() {
        switch bookingState {
        case .editPickLocation(let locationType):
            let o = mutableBooking.booking.map { locationType == .origin ? $0.originAddress : ($0.destinationAddress1 ?? $0.originAddress) }
            o.map { $0.subLocality }
                .bind(to: addressSubject)
                .disposeOnDeactivate(interactor: self)

            o.map { $0.coordinate }
                .bind(to: locationSubject)
                .disposeOnDeactivate(interactor: self)

        default:
            let o = mutableBooking.booking.map { $0.originAddress }
            o.map { $0.subLocality }
                .bind(to: addressSubject)
                .disposeOnDeactivate(interactor: self)

            o.map { $0.coordinate }
                .bind(to: locationSubject)
                .disposeOnDeactivate(interactor: self)
        }
    }

//    private func resetToPreviousLocation() {
//        mutableBooking.booking.map { $0.originAddress }
//            .bind { [weak self] (originAddress) in
//                self?.mutableBooking.updateBooking(originAddress: originAddress)
//            }
//            .dispose()
//    }
}
