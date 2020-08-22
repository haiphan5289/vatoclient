//  File name   : BookingRequestBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 1/10/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase

// MARK: Dependency
protocol BookingRequestDependency: Dependency, BookingRequestStream {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var profileStream: MutableProfileStream { get }
//    var location: LocationStream { get }
}

final class BookingRequestComponent: Component<BookingRequestDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BookingRequestBuildable: Buildable {
    func build(withListener listener: BookingRequestListener) -> BookingRequestRouting
}

final class BookingRequestBuilder: Builder<BookingRequestDependency>, BookingRequestBuildable {

    override init(dependency: BookingRequestDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: BookingRequestListener) -> BookingRequestRouting {
        let component = BookingRequestComponent(dependency: dependency)
        let viewController = BookingRequestVC()

        let interactor = BookingRequestInteractor(presenter: viewController, dependency: component.dependency)
        interactor.listener = listener

        return BookingRequestRouter(interactor: interactor, viewController: viewController)
    }
}
