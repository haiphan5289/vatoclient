//  File name   : CarContractBuilder.swift
//
//  Author      : an.nguyen
//  Created date: 8/18/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol CarContractDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
}

final class CarContractComponent: Component<CarContractDependency> {
    /// Class's public properties.
    let CarContractVC: CarContractVC
    
    /// Class's constructor.
    init(dependency: CarContractDependency, CarContractVC: CarContractVC) {
        self.CarContractVC = CarContractVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol CarContractBuildable: Buildable {
    func build(withListener listener: CarContractListener) -> CarContractRouting
}

final class CarContractBuilder: Builder<CarContractDependency>, CarContractBuildable {
    /// Class's constructor.
    override init(dependency: CarContractDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: CarContractBuildable's members
    func build(withListener listener: CarContractListener) -> CarContractRouting {
        let vc = CarContractVC(nibName: CarContractVC.identifier, bundle: nil)
        
        let component = CarContractComponent(dependency: dependency, CarContractVC: vc)

        let interactor = CarContractInteractor(presenter: component.CarContractVC)
        interactor.listener = listener
        let ordertContract = OrderContractBuilder(dependency: component)
        let location = LocationPickerBuilder(dependency: component)

        // todo: Create builder modules builders and inject into router here.
        
        return CarContractRouter(interactor: interactor,
                                 viewController: component.CarContractVC,
                                 ordertContract: ordertContract,
                                 locationBuilder: location)
    }
}
