//  File name   : MainDeliveryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/15/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol MainDeliveryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var bookingPoints: BookingStream { get }
    var firebaseDatabase: DatabaseReference  { get }
    var mutableProfile: MutableProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var mutableBookingStream: MutableBookingStream { get }
}

typealias BookingConfirmDeliveryType = BookingConfirmComponentProtocol & BookingConfirmPointsProtocol & BookingConfirmPaymentProtocol & BookingConfirmProfileProtocol & BookingConfirmSecurityProtocol
final class MainDeliveryComponent: Component<MainDeliveryDependency>, BookingConfirmDeliveryType {
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
    
//    var mutablePaymentStream: MutablePaymentStream {
//        return dependency.mutablePaymentStream
//    }
    
    var profileStream: MutableProfileStream {
        return dependency.mutableProfile
    }
    
    /// Class's public properties.
    let MainDeliveryVC: MainDeliveryVC
    
    /// Class's constructor.
    init(dependency: MainDeliveryDependency, MainDeliveryVC: MainDeliveryVC) {
        self.MainDeliveryVC = MainDeliveryVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol MainDeliveryBuildable: Buildable {
    func build(withListener listener: MainDeliveryListener) -> MainDeliveryRouting
}

final class MainDeliveryBuilder: Builder<MainDeliveryDependency>, MainDeliveryBuildable {
    /// Class's constructor.
    override init(dependency: MainDeliveryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: MainDeliveryBuildable's members
    func build(withListener listener: MainDeliveryListener) -> MainDeliveryRouting {
        let vc = MainDeliveryVC()
        let component = MainDeliveryComponent(dependency: dependency, MainDeliveryVC: vc)
        
        let interactor = MainDeliveryInteractor(presenter: component.MainDeliveryVC, component: component)
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
        let fillInformationBuildable = FillInformationBuilder(dependency: component)
        let searchDeliveryBuildable = LocationPickerBuilder(dependency: component)
        let confirmBookingServiceMoreBuilder = ConfirmBookingServiceMoreBuilder(dependency: component)
        let pinAddressBuilder = PinAddressBuilder(dependency: component)
        let intripBuilder = InTripBuilder(dependency: component)
        let walletBuilder = WalletBuilder(dependency: component)
        
        let router = MainDeliveryRouter(interactor: interactor,
                                        controller: vc,
                                        tipBuilder: tipBuilder,
                                        changeMethod: confirmChangeMethodBuilder,
                                        promotionBuilder: promotionBuilder,
                                        promotionListBuilder: promotionListBuilder,
                                        promotionDetailBuilder: promotionDetailBuilder,
                                        bookingRequestBuilder: bookingRequestBuilder,
                                        switchPaymentBuilder: switchPaymentBuilder,
                                        confirmDetailBuildable: detailBuilder,
                                        noteDeliveryBuildable: noteDeliverBuilder,
                                        fillInformationBuildable: fillInformationBuildable,
                                        searchDeliveryBuildable: searchDeliveryBuildable,
                                        confirmBookingServiceMoreBuildable: confirmBookingServiceMoreBuilder,
                                        pinAddressBuilable: pinAddressBuilder,
                                        inTripBuildable: intripBuilder,
                                        walletBuildable: walletBuilder)

        return router
    }
}
