//  File name   : PromotionDetailBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/23/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol PromotionDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class PromotionDetailComponent: Component<PromotionDetailDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol PromotionDetailBuildable: Buildable {
    func build(withListener listener: PromotionDetailListener, mode: PromotionDetailPresentation, manifest: PromotionList.Manifest?, code: String) -> PromotionDetailRouting
}

final class PromotionDetailBuilder: Builder<PromotionDetailDependency>, PromotionDetailBuildable {

    override init(dependency: PromotionDetailDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PromotionDetailListener, mode: PromotionDetailPresentation, manifest: PromotionList.Manifest?, code: String) -> PromotionDetailRouting {
//        let component = PromotionDetailComponent(dependency: dependency)
        let viewController = PromotionDetailVC()

        let interactor = PromotionDetailInteractor(presenter: viewController, with: mode, manifest: manifest, code: code)
        interactor.listener = listener
        
        return PromotionDetailRouter(interactor: interactor, viewController: viewController)
    }
}
