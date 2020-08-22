//  File name   : ShoppingFillInformationBuilder.swift
//
//  Author      : khoi tran
//  Created date: 4/3/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ShoppingFillInformationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var profileStream: MutableProfileStream { get }
    var bookingPoints: BookingStream { get }
}

final class ShoppingFillInformationComponent: Component<ShoppingFillInformationDependency> {
    /// Class's public properties.
    let ShoppingFillInformationVC: ShoppingFillInformationVC
    
    /// Class's constructor.
    init(dependency: ShoppingFillInformationDependency, ShoppingFillInformationVC: ShoppingFillInformationVC) {
        self.ShoppingFillInformationVC = ShoppingFillInformationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ShoppingFillInformationBuildable: Buildable {
    func build(withListener listener: ShoppingFillInformationListener, old: DeliveryInputInformation) -> ShoppingFillInformationRouting
}

final class ShoppingFillInformationBuilder: Builder<ShoppingFillInformationDependency>, ShoppingFillInformationBuildable {
    /// Class's constructor.
    override init(dependency: ShoppingFillInformationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ShoppingFillInformationBuildable's members
    func build(withListener listener: ShoppingFillInformationListener, old: DeliveryInputInformation) -> ShoppingFillInformationRouting {
        let vc = ShoppingFillInformationVC()
        let component = ShoppingFillInformationComponent(dependency: dependency, ShoppingFillInformationVC: vc)

        let interactor = ShoppingFillInformationInteractor(presenter: component.ShoppingFillInformationVC, old: old, profileStream: dependency.profileStream, bookingPoints: dependency.bookingPoints, authenticated: dependency.authenticated)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ShoppingFillInformationRouter(interactor: interactor,
                                             viewController: component.ShoppingFillInformationVC,
                                             searchAddressBuildable: LocationPickerBuilder(dependency: component), pinAddressBuildable: PinAddressBuilder(dependency: component))
    }
}
