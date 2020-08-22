//  File name   : FillInformationBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FillInformationDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var profileStream: MutableProfileStream { get }
    var bookingPoints: BookingStream { get }
}

final class FillInformationComponent: Component<FillInformationDependency> {
    /// Class's public properties.
    let FillInformationVC: FillInformationVC
    
    /// Class's constructor.
    init(dependency: FillInformationDependency, FillInformationVC: FillInformationVC) {
        self.FillInformationVC = FillInformationVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FillInformationBuildable: Buildable {
    func build(withListener listener: FillInformationListener, value: DeliveryInputInformation, serviceType: DeliveryServiceType) -> FillInformationRouting
}

final class FillInformationBuilder: Builder<FillInformationDependency>, FillInformationBuildable {
    /// Class's constructor.
    override init(dependency: FillInformationDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FillInformationBuildable's members
    func build(withListener listener: FillInformationListener, value: DeliveryInputInformation, serviceType: DeliveryServiceType) -> FillInformationRouting {
        let vc = FillInformationVC(type: value.type)
        let component = FillInformationComponent(dependency: dependency, FillInformationVC: vc)

        let interactor = FillInformationInteractor(presenter: component.FillInformationVC,
                                                   old: value,
                                                   profileStream: dependency.profileStream,
                                                   bookingPoints: dependency.bookingPoints,
                                                   serviceType: serviceType,
                                                   authenticated: dependency.authenticated)
        interactor.listener = listener
        
        let searchDeliveryBuildable = LocationPickerBuilder(dependency: component)
        let pinAddressBuilder = PinAddressBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return FillInformationRouter(interactor: interactor,
                                     viewController: component.FillInformationVC,
                                     searchDeliveryBuildable: searchDeliveryBuildable,
                                     pinAddressBuildable: pinAddressBuilder)
    }
}
