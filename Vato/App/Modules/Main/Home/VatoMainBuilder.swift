//  File name   : VatoMainBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/23/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

// MARK: Dependency tree
protocol VatoMainDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableAuthenticated: MutableAuthenticatedStream { get }
    var mutableProfile: MutableProfileStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePromotionNows: MutablePromotionNowStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var mutableBookingStream: MutableBookingStream { get }
}

final class VatoMainComponent: Component<VatoMainDependency> {
    /// Class's public properties.
    let VatoMainVC: VatoMainVC
    
    /// Class's constructor.
    init(dependency: VatoMainDependency, VatoMainVC: VatoMainVC) {
        self.VatoMainVC = VatoMainVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol VatoMainBuildable: Buildable {
    func build(withListener listener: VatoMainListener) -> VatoMainRouting
}

final class VatoMainBuilder: Builder<VatoMainDependency>, VatoMainBuildable {
    /// Class's constructor.
    override init(dependency: VatoMainDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: VatoMainBuildable's members
    func build(withListener listener: VatoMainListener) -> VatoMainRouting {
        let vc = VatoMainVC()
        let component = VatoMainComponent(dependency: dependency, VatoMainVC: vc)
        let latePaymentBuilder = LatePaymentBuilder(dependency: component)
        
        let interactor = VatoMainInteractor(presenter: component.VatoMainVC,
                                            profileStream: component.dependency.mutableProfile,
                                            authenticated: component.dependency.mutableAuthenticated,
                                            firebaseDatabase: component.dependency.firebaseDatabase,
                                            mutablePromotionNows: component.dependency.mutablePromotionNows,
                                            paymentStream: component.dependency.mutablePaymentStream,
                                            mutableBookingStream: component.dependency.mutableBookingStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let scanQRBuilder = ScanQRBuilder(dependency: component)
        let inTripBuilder = InTripBuilder(dependency: component)
        
        return VatoMainRouter(interactor: interactor,
                              viewController: component.VatoMainVC,
                              scanQRBuildable: scanQRBuilder,
                              latePaymentBuildable: latePaymentBuilder,
                              setLocationBuildable: SetLocationBuilder(dependency: component),
                              inTripBuildable: inTripBuilder)
    }
}
