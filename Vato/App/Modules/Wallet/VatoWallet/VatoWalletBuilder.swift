//  File name   : VatoWalletBuilder.swift
//
//  Author      : Phuc Tran
//  Created date: 8/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol VatoWalletDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class VatoWalletComponent: Component<VatoWalletDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol VatoWalletBuildable: Buildable {
    func build(withListener listener: VatoWalletListener) -> VatoWalletRouting
}

final class VatoWalletBuilder: Builder<VatoWalletDependency>, VatoWalletBuildable {
    override init(dependency: VatoWalletDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: VatoWalletListener) -> VatoWalletRouting {
        let component = VatoWalletComponent(dependency: dependency)
        let viewController = VatoWalletVC()

        let interactor = VatoWalletInteractor(presenter: viewController)
        interactor.listener = listener

        return VatoWalletRouter(interactor: interactor, viewController: viewController)
    }
}
