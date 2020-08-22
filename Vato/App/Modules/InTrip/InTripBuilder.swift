//  File name   : InTripBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 3/10/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol InTripDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var profile: ProfileStream { get }
    var authenticated: AuthenticatedStream { get }
    var mutablePaymentStream: MutablePaymentStream { get }
    var mutableBookingStream: MutableBookingStream { get }
}

final class InTripComponent: Component<InTripDependency> {
    /// Class's public properties.
    let InTripVC: InTripVC
    
    /// Class's constructor.
    init(dependency: InTripDependency, InTripVC: InTripVC) {
        self.InTripVC = InTripVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
    var mutableChatStream: MutableChatStream {
        return shared { ChatStreamImpl(with: nil) }
    }
}

// MARK: Builder
protocol InTripBuildable: Buildable {
    func build(withListener listener: InTripListener, tripId: String) -> InTripRouting
}

final class InTripBuilder: Builder<InTripDependency>, InTripBuildable {
    /// Class's constructor.
    override init(dependency: InTripDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: InTripBuildable's members
    func build(withListener listener: InTripListener, tripId: String) -> InTripRouting {
        let vc = InTripVC()
        let component = InTripComponent(dependency: dependency, InTripVC: vc)

        let interactor = InTripInteractor(presenter: component.InTripVC,
                                          tripId: tripId,
                                          mutableChatStream: component.mutableChatStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let chatBuilder = ChatBuilder(dependency: component)
        let shortcutBuilder = TOShortcutBuilder(dependency: component)
        let locationPickerBuilder = LocationPickerBuilder(dependency: component)
        return InTripRouter(interactor: interactor,
                            viewController: component.InTripVC,
                            chatBuildable: chatBuilder,
                            shortcutBuildable: shortcutBuilder,
                            addDestinationConfirmBuildable: AddDestinationConfirmBuilder(dependency: component),
                            locationPickerBuildable: locationPickerBuilder)
    }
}
