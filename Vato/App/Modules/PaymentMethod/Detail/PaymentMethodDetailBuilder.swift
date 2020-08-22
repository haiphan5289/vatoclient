//  File name   : PaymentMethodDetailBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol PaymentMethodDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var profileStream: ProfileStream { get }
}

final class PaymentMethodDetailComponent: Component<PaymentMethodDetailDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol PaymentMethodDetailBuildable: Buildable {
    func build(withListener listener: PaymentMethodDetailListener, detail: PaymentCardDetail) -> PaymentMethodDetailRouting
}

final class PaymentMethodDetailBuilder: Builder<PaymentMethodDetailDependency>, PaymentMethodDetailBuildable {

    override init(dependency: PaymentMethodDetailDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PaymentMethodDetailListener, detail: PaymentCardDetail) -> PaymentMethodDetailRouting {
        let component = PaymentMethodDetailComponent(dependency: dependency)
        let viewController = PaymentMethodDetailVC()

        let interactor = PaymentMethodDetailInteractor(presenter: viewController,
                                                       authenticated: component.dependency.authenticated,
                                                       cardDetail: detail, profileStream: component.dependency.profileStream)
        interactor.listener = listener

        return PaymentMethodDetailRouter(interactor: interactor, viewController: viewController)
    }
}
