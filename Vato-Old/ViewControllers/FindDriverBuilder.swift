//  File name   : FindDriverBuilder.swift
//
//  Author      : admin
//  Created date: 6/24/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FindDriverDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class FindDriverComponent: Component<FindDriverDependency> {
    /// Class's public properties.
    let FindDriverVC: FindDriverVC
    
    /// Class's constructor.
    init(dependency: FindDriverDependency, FindDriverVC: FindDriverVC) {
        self.FindDriverVC = FindDriverVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FindDriverBuildable: Buildable {
    func build(withListener listener: FindDriverListener) -> FindDriverRouting
}

final class FindDriverBuilder: Builder<FindDriverDependency>, FindDriverBuildable {
    /// Class's constructor.
    override init(dependency: FindDriverDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FindDriverBuildable's members
    func build(withListener listener: FindDriverListener) -> FindDriverRouting {
        let vc = FindDriverVC()
        let component = FindDriverComponent(dependency: dependency, FindDriverVC: vc)

        let interactor = FindDriverInteractor(presenter: component.FindDriverVC)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let blockDriverDetailBuilder = BlockDriverDetailBuilder(dependency: component)
        
        return FindDriverRouter(interactor: interactor, viewController: component.FindDriverVC, blockDriverDetailBuildable: blockDriverDetailBuilder)
    }
}
