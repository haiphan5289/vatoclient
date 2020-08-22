//  File name   : EcomPromotionBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 6/26/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol EcomPromotionDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class EcomPromotionComponent: Component<EcomPromotionDependency> {
    /// Class's public properties.
    let EcomPromotionVC: EcomPromotionVC
    
    /// Class's constructor.
    init(dependency: EcomPromotionDependency, EcomPromotionVC: EcomPromotionVC) {
        self.EcomPromotionVC = EcomPromotionVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol EcomPromotionBuildable: Buildable {
    func build(withListener listener: EcomPromotionListener, storeID: Int) -> EcomPromotionRouting
}

final class EcomPromotionBuilder: Builder<EcomPromotionDependency>, EcomPromotionBuildable {
    /// Class's constructor.
    override init(dependency: EcomPromotionDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: EcomPromotionBuildable's members
    func build(withListener listener: EcomPromotionListener, storeID: Int) -> EcomPromotionRouting {
        let vc = EcomPromotionVC.init(nibName: EcomPromotionVC.identifier, bundle: nil)
        let component = EcomPromotionComponent(dependency: dependency, EcomPromotionVC: vc)

        let interactor = EcomPromotionInteractor(presenter: component.EcomPromotionVC, storeID: storeID)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return EcomPromotionRouter(interactor: interactor, viewController: component.EcomPromotionVC)
    }
}
