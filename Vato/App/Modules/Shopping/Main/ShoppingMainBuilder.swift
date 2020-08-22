//  File name   : ShoppingMainBuilder.swift
//
//  Author      : khoi tran
//  Created date: 4/1/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ShoppingMainDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var bookingPoints: BookingStream { get }
    var firebaseDatabase: DatabaseReference  { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var mutableBookingStream: MutableBookingStream { get }
}

typealias BookingConfirmShoppingType = BookingConfirmComponentProtocol & BookingConfirmPointsProtocol & BookingConfirmPaymentProtocol & BookingConfirmProfileProtocol & BookingConfirmSecurityProtocol

final class ShoppingMainComponent: Component<ShoppingMainDependency>, BookingConfirmShoppingType {
    var authenticated: AuthenticatedStream {
        return dependency.authenticated
    }
    
    var mutablePaymentStream: MutablePaymentStream {
        return dependency.mutablePaymentStream
    }
    
    
    /// Class's public properties.
    let ShoppingMainVC: ShoppingMainVC
    
    var confirmStream: ConfirmStreamImpl {
        return shared({
            let model = BookingConfirmInformation()
            return ConfirmStreamImpl(with: model)
        })
    }
    
    var currentModelBook: BookingConfirmInformation {
        return confirmStream.model
    }
    
    var firebaseDatabase: DatabaseReference {
        return dependency.firebaseDatabase
    }
    
    var bookingPoints: BookingStream {
        return dependency.bookingPoints
    }
    
    var profileStream: MutableProfileStream {
        return dependency.mutableProfile
    }
    /// Class's constructor.
    init(dependency: ShoppingMainDependency, ShoppingMainVC: ShoppingMainVC) {
        self.ShoppingMainVC = ShoppingMainVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ShoppingMainBuildable: Buildable {
    func build(withListener listener: ShoppingMainListener) -> ShoppingMainRouting
}

final class ShoppingMainBuilder: Builder<ShoppingMainDependency>, ShoppingMainBuildable {
    /// Class's constructor.
    override init(dependency: ShoppingMainDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ShoppingMainBuildable's members
    func build(withListener listener: ShoppingMainListener) -> ShoppingMainRouting {
        let vc = ShoppingMainVC()
        let component = ShoppingMainComponent(dependency: dependency, ShoppingMainVC: vc)

        let interactor = ShoppingMainInteractor(presenter: component.ShoppingMainVC, component: component)
        interactor.listener = listener

        let tipBuilder = TipBuilder(dependency: component)
        let confirmChangeMethodBuilder = ConfirmBookingChangeMethodBuilder(dependency: component)
        let promotionBuilder = BookingConfirmPromotionBuilder(dependency: component)
        let promotionListBuilder = PromotionBuilder(dependency: component)
        let promotionDetailBuilder = PromotionDetailBuilder(dependency: component)
        let bookingRequestBuilder = BookingRequestBuilder(dependency: component)
        let switchPaymentBuilder = SwitchPaymentBuilder(dependency: component)
        let noteDeliverBuilder = NoteDeliveryBuilder(dependency: component)
        let detailBuilder = ConfirmDetailBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        let locationPickerBuidler = LocationPickerBuilder(dependency: component)
        let pinAddressBuilder = PinAddressBuilder(dependency: component)
        let shoppingFillInformationBuilder = ShoppingFillInformationBuilder(dependency: component)
        let confirmBookingServiceMoreBuilder = ConfirmBookingServiceMoreBuilder(dependency: component)
        
        let intripBuilder = InTripBuilder(dependency: component)
        return ShoppingMainRouter(interactor: interactor,
                                  viewController: component.ShoppingMainVC,
                                  locationPickerBuildable: locationPickerBuidler,
                                  pinAddressBuilable: pinAddressBuilder,
                                  shoppingFillInformationBuilable: shoppingFillInformationBuilder,
                                  tipBuilder: tipBuilder,
                                  changeMethod: confirmChangeMethodBuilder,
                                  promotionBuilder: promotionBuilder,
                                  promotionListBuilder: promotionListBuilder,
                                  promotionDetailBuilder: promotionDetailBuilder,
                                  bookingRequestBuilder: bookingRequestBuilder,
                                  switchPaymentBuilder: switchPaymentBuilder,
                                  confirmDetailBuildable: detailBuilder,
                                  confirmBookingServiceMoreBuildable: confirmBookingServiceMoreBuilder,
                                  noteDeliveryBuildable: noteDeliverBuilder,
                                  inTripBuildable: intripBuilder)
    }
}
