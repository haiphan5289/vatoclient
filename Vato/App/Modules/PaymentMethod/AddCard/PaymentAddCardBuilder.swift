//  File name   : PaymentAddCardBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol PaymentAddCardDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
}

final class PaymentAddCardComponent: Component<PaymentAddCardDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol PaymentAddCardBuildable: Buildable {
    func build(withListener listener: PaymentAddCardListener, url: URL) -> PaymentAddCardRouting
}

final class PaymentAddCardBuilder: Builder<PaymentAddCardDependency>, PaymentAddCardBuildable {

    override init(dependency: PaymentAddCardDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PaymentAddCardListener, url: URL) -> PaymentAddCardRouting {
        let component = PaymentAddCardComponent(dependency: dependency)
        let viewController = PaymentAddCardVC()

        let interactor = PaymentAddCardInteractor(presenter: viewController,
                                                  url: url,
                                                  authenticated: component.dependency.authenticated)
        interactor.listener = listener

        return PaymentAddCardRouter(interactor: interactor, viewController: viewController)
    }
}
