//  File name   : SearchLocationBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import GoogleMaps
import RIBs

// MARK: Dependency
protocol SearchLocationDependency: Dependency {
    var searchLocationVC: SearchLocationViewControllable { get }

    var mutableBooking: MutableBookingStream { get }
    var bookingState: BookingState { get }

    var currentLocation: CLLocationCoordinate2D { get }
    var googleAPIKey: String { get }
    
    var authStream: AuthenticatedStream { get }
}

final class SearchLocationComponent: Component<SearchLocationDependency> {
    /// Class's public properties.

    /// Class's constructors.
    override init(dependency: SearchLocationDependency) {
        super.init(dependency: dependency)
    }

    /// Class's private properties.
    fileprivate var searchLocationVC: SearchLocationViewControllable {
        return dependency.searchLocationVC
    }

    fileprivate var mutableBooking: MutableBookingStream {
        return dependency.mutableBooking
    }

    fileprivate var bookingState: BookingState {
        return dependency.bookingState
    }

    fileprivate var currentLocation: CLLocationCoordinate2D {
        return dependency.currentLocation
    }

    fileprivate var googleAPIKey: String {
        return dependency.googleAPIKey
    }
    
    fileprivate var authStream: AuthenticatedStream {
        return dependency.authStream
    }
}

// MARK: Builder
protocol SearchLocationBuildable: Buildable {
    func build(withListener listener: SearchLocationListener) -> SearchLocationRouting
}

final class SearchLocationBuilder: Builder<SearchLocationDependency>, SearchLocationBuildable {
    override init(dependency: SearchLocationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SearchLocationListener) -> SearchLocationRouting {
        let component = SearchLocationComponent(dependency: dependency)

        let interactor = SearchLocationInteractor(bookingStream: component.mutableBooking,
                                                  authStream: component.authStream,
                                                  currentLocation: component.currentLocation,
                                                  googleAPIKey: component.googleAPIKey,
                                                  state: component.bookingState)
        interactor.listener = listener

        return SearchLocationRouter(interactor: interactor,
                                    viewController: component.searchLocationVC,
                                    state: component.bookingState)
    }
}
