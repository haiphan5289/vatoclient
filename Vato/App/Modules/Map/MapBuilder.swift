//  File name   : MapBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import CoreLocation
import Firebase
import FwiCore
import RIBs

// MARK: Dependency
protocol MapDependency: Dependency {
    var firebaseDatabase: DatabaseReference { get }

    var mutableAuthenticated: MutableAuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }

    var mutableDisplayPromotionNow: MutableDisplayPromotionNowStream { get }
}

final class MapComponent: Component<MapDependency> {
    /// Class's public properties.
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }

    var mutableAuthenticated: MutableAuthenticatedStream {
        return dependency.mutableAuthenticated
    }

    var mutableProfile: MutableProfileStream {
        return dependency.mutableProfile
    }

    var mutableBooking: MutableBookingStream {
        return shared { BookingStreamImpl() }
    }

    var bookingState: BookingState {
        var step = BookingState.none
        mutableBooking.mode.subscribe(onNext: { step = $0 }).dispose()

        return step
    }

    var googleAPIKey: String {
        var key = ""
        dependency.mutableAuthenticated.googleAPI.subscribe(onNext: { key = $0 }).dispose()
        return key
    }

    let mapVC: MapVC

    /// Class's constructors.
    init(dependency: MapDependency, with mapVC: MapVC) {
        self.mapVC = mapVC
        super.init(dependency: dependency)
    }

    /// Class's private properties.
    fileprivate var mutableDisplayPromotionNow: MutableDisplayPromotionNowStream {
        return dependency.mutableDisplayPromotionNow
    }
}

// MARK: Builder
protocol MapBuildable: Buildable {
    func build(withListener listener: MapListener, data: VatoMainData?) -> MapRouting
}

final class MapBuilder: Builder<MapDependency>, MapBuildable {
    override init(dependency: MapDependency) {
        super.init(dependency: dependency)
    }
    
    func build(withListener listener: MapListener, data: VatoMainData?) -> MapRouting {
        let viewController = MapVC(nibName: MapVC.identifier, bundle: nil)
        let component = MapComponent(dependency: dependency,
                                     with: viewController)

        let interactor = MapInteractor(presenter: viewController,
                                       mutableAuthenticated: component.mutableAuthenticated,
                                       mutableBooking: component.mutableBooking,
                                       firebaseDatabase: component.firebaseDatabase,
                                       googleAPIKey: component.googleAPIKey,
                                       mutableDisplayPromotionNow: component.mutableDisplayPromotionNow,
                                       paymentStream: component.mutablePaymentStream,
                                       data: data)

        interactor.listener = listener

        let homeBuilder = HomeBuilder(dependency: component)
        let bookingConfirmBuilder = BookingConfirmBuilder(dependency: component)
        let searchLocationBuilder = SearchLocationBuilder(dependency: component)
        let pickLocationBuilder = PickLocationBuilder(dependency: component)

        let promotionBuilder = PromotionBuilder(dependency: component)
        let promotionDetailBuilder = PromotionDetailBuilder(dependency: component)
        let mainDeliverBuilder = MainDeliveryBuilder(dependency: component)
        let vatoTaxiBuilder = VatoTaxiBuilder(dependency: component)
        let locationPickerBuilder = LocationPickerBuilder(dependency: component)
        let setLocationBuilder = SetLocationBuilder(dependency: component)
        
//        let contractBuilder = BookContractBuilder(dependency: component)
        let contractBuilder = CarContractBuilder(dependency: component)
        
        return MapRouter(interactor: interactor,
                         viewController: viewController,
                         homeBuilder: homeBuilder,
                         searchLocationBuilder: searchLocationBuilder,
                         bookingConfirmBuilder: bookingConfirmBuilder,
                         pickLocationBuilder: pickLocationBuilder,
                         promotionBuilder: promotionBuilder,
                         promotionDetailBuilder: promotionDetailBuilder,
                         mainDeliveryBuildable: mainDeliverBuilder,
                         vatoTaxiBuildable: vatoTaxiBuilder,
                         locationPickerBuildable: locationPickerBuilder,
                         setLocationBuildable: setLocationBuilder,
                         contractBuildable: contractBuilder)
    }
}
