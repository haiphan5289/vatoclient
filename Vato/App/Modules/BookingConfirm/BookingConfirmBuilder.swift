//  File name   : BookingConfirmBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import GoogleMaps
import RIBs

// MARK: Dependency
protocol BookingConfirmDependency: ConfirmBookingChangeMethodDependency {
    // todo: Make sure to convert the variable into lower-camelcase.
    var bookingConfirmVC: BookingConfirmViewControllable { get }
    var mapView: GMSMapView { get }

    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var bookingPoints: BookingStream { get }
    var mutableBookingState: MutableBookingStateStream { get }
    var mutableBooking: MutableBookingStream { get }

    // database
    var firebaseDatabase: DatabaseReference { get }

    // authen key
    var authenticated: AuthenticatedStream { get }

    // profile
    var profileStream: MutableProfileStream { get }
    
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class BookingConfirmComponent: Component<BookingConfirmDependency>, BookingConfirmServicesType {
    fileprivate var bookingConfirmVC: BookingConfirmViewControllable {
        return dependency.bookingConfirmVC
    }

    var confirmStream: ConfirmStreamImpl {
        return shared({
            let model = BookingConfirmInformation()
            return ConfirmStreamImpl(with: model)
        })
    }
    
    var mutableBookingState: MutableBookingStateStream {
        return dependency.mutableBookingState
    }
    
    var mutableBooking: MutableBookingStream {
        return dependency.mutableBooking
    }

    var json: [String: Any] {
        return confirmStream.model.exportJson() ?? [:]
    }

    var profileStream: MutableProfileStream {
        return dependency.profileStream
    }

    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var bookingPoints: BookingStream {
        return dependency.bookingPoints
    }
}

// MARK: Builder
protocol BookingConfirmBuildable: Buildable {
    func build(withListener listener: BookingConfirmListener) -> BookingConfirmRouting
}

final class BookingConfirmBuilder: Builder<BookingConfirmDependency>, BookingConfirmBuildable {
    override init(dependency: BookingConfirmDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: BookingConfirmListener) -> BookingConfirmRouting {
        let component = BookingConfirmComponent(dependency: dependency)
        let interactor = BookingConfirmInteractor(component: component)
        interactor.listener = listener
        let noteBuilder = NoteBuilder(dependency: component)
        let transportBuilder = TransportServiceBuilder(dependency: component)
        let tipBuilder = TipBuilder(dependency: component)
        let confirmChangeMethodBuilder = ConfirmBookingChangeMethodBuilder(dependency: component.dependency)
        let detailBuilder = ConfirmDetailBuilder(dependency: component)
        let promotionBuilder = BookingConfirmPromotionBuilder(dependency: component)

        let promotionListBuilder = PromotionBuilder(dependency: component)
        let promotionDetailBuilder = PromotionDetailBuilder(dependency: component)
        let bookingRequestBuilder = BookingRequestBuilder(dependency: component)
        let switchPaymentBuilder = SwitchPaymentBuilder(dependency: component)
        let confirmBookingServiceMoreBuilder = ConfirmBookingServiceMoreBuilder(dependency: component)
        let inTripBuilder = InTripBuilder(dependency: component)
        let walletBuilder = WalletBuilder(dependency: component)
        
        return BookingConfirmRouter(interactor: interactor,
                                    viewController: component.bookingConfirmVC,
                                    noteController: noteBuilder,
                                    mapView: component.dependency.mapView,
                                    transportService: transportBuilder,
                                    tipBuilder: tipBuilder,
                                    changeMethod: confirmChangeMethodBuilder,
                                    detailBuilder: detailBuilder,
                                    promotionBuilder: promotionBuilder,
                                    promotionListBuilder: promotionListBuilder,
                                    promotionDetailBuilder: promotionDetailBuilder,
                                    bookingRequestBuilder: bookingRequestBuilder,
                                    switchPaymentBuilder: switchPaymentBuilder,
                                    confirmBookingServiceMoreBuilder: confirmBookingServiceMoreBuilder,
                                    inTripBuildable: inTripBuilder,
                                    walletBuildable: walletBuilder)
    }
}
