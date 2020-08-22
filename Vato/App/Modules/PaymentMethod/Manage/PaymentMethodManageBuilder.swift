//  File name   : PaymentMethodManageBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

// MARK: Dependency
protocol PaymentMethodManageDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var profileStream: ProfileStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var firebaseDatabase: DatabaseReference { get }
}

final class PaymentMethodManageComponent: Component<PaymentMethodManageDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol PaymentMethodManageBuildable: Buildable {
    func build(withListener listener: PaymentMethodManageListener) -> PaymentMethodManageRouting
}

final class PaymentMethodManageBuilder: Builder<PaymentMethodManageDependency>, PaymentMethodManageBuildable {

    override init(dependency: PaymentMethodManageDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PaymentMethodManageListener) -> PaymentMethodManageRouting {
        let component = PaymentMethodManageComponent(dependency: dependency)
        let viewController = PaymentMethodManageVC()

        let interactor = PaymentMethodManageInteractor(presenter: viewController,
                                                       authenticated: component.dependency.authenticated,
                                                       paymentStream: component.dependency.mutablePaymentStream,
                                                       firebaseDatabase: component.dependency.firebaseDatabase)
        interactor.listener = listener
        
        let paymentAddCardBuilder = PaymentAddCardBuilder(dependency: component)
        let paymentMethodDetailBuilder = PaymentMethodDetailBuilder(dependency: component)

        return PaymentMethodManageRouter(interactor: interactor,
                                         viewController: viewController,
                                         paymentAddCardBuilder: paymentAddCardBuilder,
                                         paymentMethodDetailBuilder: paymentMethodDetailBuilder)
    }
}
