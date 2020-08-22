//  File name   : ConfirmBookingChangeMethodBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/1/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import Firebase
import RIBs

// MARK: Dependency
protocol ConfirmBookingChangeMethodDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var firebaseDatabase: DatabaseReference { get }
}

final class ConfirmBookingChangeMethodComponent: Component<ConfirmBookingChangeMethodDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ConfirmBookingChangeMethodBuildable: Buildable {
    func build(withListener listener: ConfirmBookingChangeMethodListener) -> ConfirmBookingChangeMethodRouting
}

final class ConfirmBookingChangeMethodBuilder: Builder<ConfirmBookingChangeMethodDependency>, ConfirmBookingChangeMethodBuildable {
    override init(dependency: ConfirmBookingChangeMethodDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ConfirmBookingChangeMethodListener) -> ConfirmBookingChangeMethodRouting {
        let component = ConfirmBookingChangeMethodComponent(dependency: dependency)
        let viewController = ConfirmBookingChangeMethodVC()

        let interactor = ConfirmBookingChangeMethodInteractor(presenter: viewController, firebaseDatabase: component.dependency.firebaseDatabase)
        interactor.listener = listener

        return ConfirmBookingChangeMethodRouter(interactor: interactor, viewController: viewController)
    }
}
