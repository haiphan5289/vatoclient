//  File name   : SwitchPaymentBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/12/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

// MARK: Dependency
protocol SwitchPaymentDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var authenticatedStream: AuthenticatedStream { get }
    var mProfileStream: ProfileStream { get }
}

final class SwitchPaymentComponent: Component<SwitchPaymentDependency> {
    
    
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol SwitchPaymentBuildable: Buildable {
    func build(withListener listener: SwitchPaymentListener,
               switchPaymentType: SwitchPaymentType) -> SwitchPaymentRouting
}

final class SwitchPaymentBuilder: Builder<SwitchPaymentDependency>, SwitchPaymentBuildable {

    override init(dependency: SwitchPaymentDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SwitchPaymentListener,
               switchPaymentType: SwitchPaymentType) -> SwitchPaymentRouting {
        let component = SwitchPaymentComponent(dependency: dependency)
        let viewController = SwitchPaymentVC()

        let interactor = SwitchPaymentInteractor(presenter: viewController,
                                                 firebaseDatabase: component.dependency.firebaseDatabase,
                                                 paymentStream: component.dependency.mutablePaymentStream,
                                                 authenticatedStream: component.dependency.authenticatedStream,
                                                 profileStream: component.dependency.mProfileStream,
                                                 switchPaymentType: switchPaymentType)
        interactor.listener = listener
        let paymentMethodManageBuildabler = PaymentMethodManageBuilder(dependency: component)
        let paymentAddCardBuilder = PaymentAddCardBuilder(dependency: component)

        return SwitchPaymentRouter(interactor: interactor, viewController: viewController, paymentMethodManageBuildabler: paymentMethodManageBuildabler, paymentAddCardBuilder: paymentAddCardBuilder)
    }
}

