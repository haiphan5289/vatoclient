//  File name   : ChangeDestinationConfirmBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 4/9/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol ChangeDestinationConfirmDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class ChangeDestinationConfirmComponent: Component<ChangeDestinationConfirmDependency> {
    /// Class's public properties.
    let ChangeDestinationConfirmVC: ChangeDestinationConfirmVC
    
    /// Class's constructor.
    init(dependency: ChangeDestinationConfirmDependency, ChangeDestinationConfirmVC: ChangeDestinationConfirmVC) {
        self.ChangeDestinationConfirmVC = ChangeDestinationConfirmVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ChangeDestinationConfirmBuildable: Buildable {
    func build(withListener listener: ChangeDestinationConfirmListener, request: InTripRequestChangeDestination, tripId: String) -> ChangeDestinationConfirmRouting
}

final class ChangeDestinationConfirmBuilder: Builder<ChangeDestinationConfirmDependency>, ChangeDestinationConfirmBuildable {
    /// Class's constructor.
    override init(dependency: ChangeDestinationConfirmDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: ChangeDestinationConfirmBuildable's members
    func build(withListener listener: ChangeDestinationConfirmListener, request: InTripRequestChangeDestination, tripId: String) -> ChangeDestinationConfirmRouting {
        let vc = ChangeDestinationConfirmVC()
        let component = ChangeDestinationConfirmComponent(dependency: dependency, ChangeDestinationConfirmVC: vc)

        let interactor = ChangeDestinationConfirmInteractor(presenter: component.ChangeDestinationConfirmVC, request: request, tripId: tripId)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return ChangeDestinationConfirmRouter(interactor: interactor, viewController: component.ChangeDestinationConfirmVC)
    }
}
