//  File name   : DeliveryBookingBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol DeliveryBookingDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class DeliveryBookingComponent: Component<DeliveryBookingDependency> {
    /// Class's public properties.
    let DeliveryBookingVC: DeliveryBookingVC
    
    /// Class's constructor.
    init(dependency: DeliveryBookingDependency, DeliveryBookingVC: DeliveryBookingVC) {
        self.DeliveryBookingVC = DeliveryBookingVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol DeliveryBookingBuildable: Buildable {
    func build(withListener listener: DeliveryBookingListener) -> DeliveryBookingRouting
}

final class DeliveryBookingBuilder: Builder<DeliveryBookingDependency>, DeliveryBookingBuildable {
    /// Class's constructor.
    override init(dependency: DeliveryBookingDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: DeliveryBookingBuildable's members
    func build(withListener listener: DeliveryBookingListener) -> DeliveryBookingRouting {
        let vc = DeliveryBookingVC()
        let component = DeliveryBookingComponent(dependency: dependency, DeliveryBookingVC: vc)

        let interactor = DeliveryBookingInteractor(presenter: component.DeliveryBookingVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return DeliveryBookingRouter(interactor: interactor, viewController: component.DeliveryBookingVC)
    }
}
