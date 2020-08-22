//  File name   : PromotionSearchBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/22/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxSwift

// MARK: Dependency
protocol PromotionSearchDependency: Dependency {
    // todo: Make sure to convert the variable into lower-camelcase.
    var promotionSearchVC: PromotionSearchViewControllable { get }
    var promotionSearchStream: PromotionSearchStream { get }
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    
}

final class PromotionSearchComponent: Component<PromotionSearchDependency> {
    // todo: Make sure to convert the variable into lower-camelcase.
    fileprivate var promotionSearchVC: PromotionSearchViewControllable {
        return dependency.promotionSearchVC
    }

    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol PromotionSearchBuildable: Buildable {
    func build(withListener listener: PromotionSearchListener) -> PromotionSearchRouting
}

final class PromotionSearchBuilder: Builder<PromotionSearchDependency>, PromotionSearchBuildable {

    override init(dependency: PromotionSearchDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PromotionSearchListener) -> PromotionSearchRouting {
        let component = PromotionSearchComponent(dependency: dependency)
        let interactor = PromotionSearchInteractor(searchStream: component.dependency.promotionSearchStream)
        interactor.listener = listener
        
        return PromotionSearchRouter(interactor: interactor, viewController: component.promotionSearchVC)
    }
}
