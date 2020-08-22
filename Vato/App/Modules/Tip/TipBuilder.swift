//  File name   : TipBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 9/20/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol TipDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var tipStream: MutableTip { get }
}

final class TipComponent: Component<TipDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol TipBuildable: Buildable {
    func build(withListener listener: TipListener) -> TipRouting
}

final class TipBuilder: Builder<TipDependency>, TipBuildable {
    override init(dependency: TipDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TipListener) -> TipRouting {
        let component = TipComponent(dependency: dependency)
        let viewController = TipVC()

        let interactor = TipInteractor(presenter: viewController, tipStream: component.dependency.tipStream)
        interactor.listener = listener

        return TipRouter(interactor: interactor, viewController: viewController)
    }
}
