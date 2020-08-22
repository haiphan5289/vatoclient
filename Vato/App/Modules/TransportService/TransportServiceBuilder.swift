//  File name   : TransportServiceBuilder.swift
//
//  Author      : Vato
//  Created date: 9/12/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol TransportServiceDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var transportStream: MutableTransportStream { get }
    var promotionStream: MutablePromotion { get }
}

final class TransportServiceComponent: Component<TransportServiceDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TransportServiceBuildable: Buildable {
    func build(withListener listener: TransportServiceListener) -> TransportServiceRouting
}

final class TransportServiceBuilder: Builder<TransportServiceDependency>, TransportServiceBuildable {
    override init(dependency: TransportServiceDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TransportServiceListener) -> TransportServiceRouting {
        let component = TransportServiceComponent(dependency: dependency)
        let viewController = TransportServiceVC()

        let interactor = TransportServiceInteractor(presenter: viewController, transportStream: component.dependency.transportStream, promotionStream: component.dependency.promotionStream)
        interactor.listener = listener

        return TransportServiceRouter(interactor: interactor, viewController: viewController)
    }
}
