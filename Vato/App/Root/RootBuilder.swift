//  File name   : RootBuilder.swift
//
//  Author      : Phuc Tran
//  Created date: 8/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import FwiCore
import RIBs

// MARK: Dependency
protocol RootDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class RootComponent: Component<RootDependency> {
    let rootVC: RootVC

    init(dependency: RootDependency, rootVC: RootVC) {
        self.rootVC = rootVC
        super.init(dependency: dependency)
    }
}

// MARK: Builder
protocol RootBuildable: Buildable {
    func build() -> LaunchRouting
}

final class RootBuilder: Builder<RootDependency>, RootBuildable {
    override init(dependency: RootDependency) {
        super.init(dependency: dependency)
    }

    func build() -> LaunchRouting {
        let viewController = RootVC(nibName: RootVC.identifier, bundle: nil)
        let component = RootComponent(dependency: dependency, rootVC: viewController)

        let interactor = RootInteractor(presenter: viewController)
//        let loggedInBuilder = LoggedInBuilder(dependency: component)
        let loggedOutBuilder = LoggedOutBuilder(dependency: component)

        return RootRouter(interactor: interactor,
                          viewController: viewController,
                          loggedOutBuilder: loggedOutBuilder)
    }
}
