//  File name   : PickLocationBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import GoogleMaps
import RIBs

// MARK: Dependency
protocol PickLocationDependency: Dependency {
    var pickLocationVC: PickLocationViewControllable { get }
    var mapView: GMSMapView { get }

    var mutableBooking: MutableBookingStream { get }
    var authStream: AuthenticatedStream { get }
    var bookingState: BookingState { get }
    var googleAPIKey: String { get }
}

final class PickLocationComponent: Component<PickLocationDependency> {
    fileprivate var pickLocationVC: PickLocationViewControllable {
        return dependency.pickLocationVC
    }

    fileprivate var mapView: GMSMapView {
        return dependency.mapView
    }

    fileprivate var mutableBooking: MutableBookingStream {
        return dependency.mutableBooking
    }

    fileprivate var bookingState: BookingState {
        return dependency.bookingState
    }

    fileprivate var googleAPIKey: String {
        return dependency.googleAPIKey
    }
    
    fileprivate var authStream: AuthenticatedStream {
        return dependency.authStream
    }
}

// MARK: Builder
protocol PickLocationBuildable: Buildable {
    func build(withListener listener: PickLocationListener) -> PickLocationRouting
}

final class PickLocationBuilder: Builder<PickLocationDependency>, PickLocationBuildable {
    override init(dependency: PickLocationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PickLocationListener) -> PickLocationRouting {
        let component = PickLocationComponent(dependency: dependency)
        let interactor = PickLocationInteractor(mutableBooking: component.mutableBooking,
                                                authenticated: component.authStream,
                                                bookingState: component.bookingState,
                                                googleAPIKey: component.googleAPIKey)
        interactor.listener = listener

        return PickLocationRouter(interactor: interactor,
                                  viewController: component.pickLocationVC,
                                  mapView: component.mapView,
                                  bookingState: component.bookingState)
    }
}
