//  File name   : FoodMapBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/31/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FoodMapDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
}

final class FoodMapComponent: Component<FoodMapDependency> {
    /// Class's public properties.
    let FoodMapVC: FoodMapVC
    
    /// Class's constructor.
    init(dependency: FoodMapDependency, FoodMapVC: FoodMapVC) {
        self.FoodMapVC = FoodMapVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodMapBuildable: Buildable {
    func build(withListener listener: FoodMapListener, item: FoodExploreItem) -> FoodMapRouting
}

final class FoodMapBuilder: Builder<FoodMapDependency>, FoodMapBuildable {
    /// Class's constructor.
    override init(dependency: FoodMapDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodMapBuildable's members
    func build(withListener listener: FoodMapListener, item: FoodExploreItem) -> FoodMapRouting {
        guard let vc = UIStoryboard(name: "FoodDetail", bundle: nil).instantiateViewController(withIdentifier: FoodMapVC.identifier) as? FoodMapVC else {
            fatalError("Please Implement")
        }
        let component = FoodMapComponent(dependency: dependency, FoodMapVC: vc)

        let interactor = FoodMapInteractor(presenter: component.FoodMapVC, item: item)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return FoodMapRouter(interactor: interactor, viewController: component.FoodMapVC)
    }
}
