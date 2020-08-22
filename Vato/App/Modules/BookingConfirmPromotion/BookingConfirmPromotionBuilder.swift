//  File name   : BookingConfirmPromotionBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/4/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency
protocol BookingConfirmPromotionDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var priceStream: PriceStream { get }
    var promotionStream: MutablePromotion { get }
}

final class BookingConfirmPromotionComponent: Component<BookingConfirmPromotionDependency> {
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol BookingConfirmPromotionBuildable: Buildable {
    func build(withListener listener: BookingConfirmPromotionListener) -> BookingConfirmPromotionRouting
}

final class BookingConfirmPromotionBuilder: Builder<BookingConfirmPromotionDependency>, BookingConfirmPromotionBuildable {
    override init(dependency: BookingConfirmPromotionDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: BookingConfirmPromotionListener) -> BookingConfirmPromotionRouting {
        let component = BookingConfirmPromotionComponent(dependency: dependency)
        let viewController = BookingConfirmPromotionVC()

        let interactor = BookingConfirmPromotionInteractor(presenter: viewController,
                                                           authenticatedStream: component.dependency.authenticatedStream,
                                                           priceStream: component.dependency.priceStream,
                                                           promotionStream: component.dependency.promotionStream)
        interactor.listener = listener

        return BookingConfirmPromotionRouter(interactor: interactor, viewController: viewController)
    }
}
