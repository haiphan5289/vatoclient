//  File name   : ConfirmDetailBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/3/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol ConfirmDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mPriceUpdate: PriceStream { get }
    var mTransportStream: TransportStream { get }
    var mPromotionStream: PromotionStream { get }
}

final class ConfirmDetailComponent: Component<ConfirmDetailDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol ConfirmDetailBuildable: Buildable {
    func build(withListener listener: ConfirmDetailListener, service: FromService) -> ConfirmDetailRouting
}

final class ConfirmDetailBuilder: Builder<ConfirmDetailDependency>, ConfirmDetailBuildable {
    override init(dependency: ConfirmDetailDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: ConfirmDetailListener, service: FromService) -> ConfirmDetailRouting {
        let component = ConfirmDetailComponent(dependency: dependency)
        let viewController = ConfirmDetailVC(nibName: ConfirmDetailVC.identifier, bundle: nil, fromService: service)

        let interactor = ConfirmDetailInteractor(presenter: viewController, priceUpdate: component.dependency.mPriceUpdate, transportStream: component.dependency.mTransportStream, promotionStream: component.dependency.mPromotionStream)
        interactor.listener = listener

        return ConfirmDetailRouter(interactor: interactor, viewController: viewController)
    }
}
