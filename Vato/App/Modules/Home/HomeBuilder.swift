//  File name   : HomeBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import GoogleMaps
import RealmSwift
import RIBs

// MARK: Dependency
protocol HomeDependency: Dependency {
    var homeVC: HomeViewControllable { get }
    var mapView: GMSMapView { get }

    var firebaseDatabase: DatabaseReference { get }
    var authenticated: AuthenticatedStream { get }
    var profile: ProfileStream { get }

    var mutableBooking: MutableBookingStream { get }
    var googleAPIKey: String { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class HomeComponent: Component<HomeDependency> {
    fileprivate var homeVC: HomeViewControllable {
        return dependency.homeVC
    }
    fileprivate var mapView: GMSMapView {
        return dependency.mapView
    }

    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    var profile: ProfileStream {
        return dependency.profile
    }
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    fileprivate var mutableBooking: MutableBookingStream {
        return dependency.mutableBooking
    }
    fileprivate var googleAPIKey: String {
        return dependency.googleAPIKey
    }

}

// MARK: Builder
protocol HomeBuildable: Buildable {
    func build(withListener listener: HomeListener) -> HomeRouting
}

final class HomeBuilder: Builder<HomeDependency>, HomeBuildable {
    override init(dependency: HomeDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: HomeListener) -> HomeRouting {
        let component = HomeComponent(dependency: dependency)

        let interactor = HomeInteractor(authenticated: component.authenticated,
                                        profile: component.profile,
                                        mutableBooking: component.mutableBooking,
                                        firebaseDatabase: component.firebaseDatabase,
                                        googleAPIKey: component.googleAPIKey,
                                        mutablePaymentStream: component.mutablePaymentStream)
        interactor.listener = listener
        let walletBuilder = WalletBuilder(dependency: component)
        let referralBuilder = ReferralBuilder(dependency: component)
        let latePaymentBuilder = LatePaymentBuilder(dependency: component)
        let setLocationBuilder = SetLocationBuilder(dependency: component)
        return HomeRouter(interactor: interactor,
                          viewController: component.homeVC,
                          walletBuilder: walletBuilder,
                          referralBuildable: referralBuilder,
                          latePaymentBuilder: latePaymentBuilder,
                          setLocationBuildable: setLocationBuilder,
                          mapView: component.mapView)
    }
}
