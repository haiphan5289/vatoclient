//  File name   : FoodListCategoryBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 11/11/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FoodListCategoryDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var mProfileStream: ProfileStream { get }
    var mutableStoreStream: MutableStoreStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class FoodListCategoryComponent: Component<FoodListCategoryDependency> {
    /// Class's public properties.
    let FoodListCategoryVC: FoodListCategoryVC
    
    /// Class's constructor.
    init(dependency: FoodListCategoryDependency, FoodListCategoryVC: FoodListCategoryVC) {
        self.FoodListCategoryVC = FoodListCategoryVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodListCategoryBuildable: Buildable {
    func build(withListener listener: FoodListCategoryListener, current: CategoryRequestProtocol) -> FoodListCategoryRouting
}

final class FoodListCategoryBuilder: Builder<FoodListCategoryDependency>, FoodListCategoryBuildable {
    /// Class's constructor.
    override init(dependency: FoodListCategoryDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodListCategoryBuildable's members
    func build(withListener listener: FoodListCategoryListener, current: CategoryRequestProtocol) -> FoodListCategoryRouting {
        let vc = FoodListCategoryVC()
        let component = FoodListCategoryComponent(dependency: dependency, FoodListCategoryVC: vc)

        let interactor = FoodListCategoryInteractor(presenter: component.FoodListCategoryVC, authenticated: component.dependency.authenticated, current: current)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let foodListCategoryBuilder = FoodListCategoryBuilder(dependency: component)
        let foodListBuilder = FoodListBuilder(dependency: component)
        return FoodListCategoryRouter(interactor: interactor, viewController: component.FoodListCategoryVC, foodListCategoryBuildable: foodListCategoryBuilder, foodListBuildable: foodListBuilder)
    }
}
