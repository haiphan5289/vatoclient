//  File name   : FoodSearchBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 11/1/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FoodSearchDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var mProfileStream: ProfileStream { get }
    var mutableStoreStream: MutableStoreStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class FoodSearchComponent: Component<FoodSearchDependency> {
    /// Class's public properties.
    let FoodSearchVC: FoodSearchVC
    
    /// Class's constructor.
    init(dependency: FoodSearchDependency, FoodSearchVC: FoodSearchVC) {
        self.FoodSearchVC = FoodSearchVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodSearchBuildable: Buildable {
    func build(withListener listener: FoodSearchListener, type: ServiceCategoryType) -> FoodSearchRouting
}

final class FoodSearchBuilder: Builder<FoodSearchDependency>, FoodSearchBuildable {
    /// Class's constructor.
    override init(dependency: FoodSearchDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodSearchBuildable's members
    func build(withListener listener: FoodSearchListener, type: ServiceCategoryType) -> FoodSearchRouting {
        let vc = FoodSearchVC()
        let component = FoodSearchComponent(dependency: dependency, FoodSearchVC: vc)

        let interactor = FoodSearchInteractor(presenter: component.FoodSearchVC, authenticated: component.dependency.authenticated, type: type)
        interactor.listener = listener
        let foodDetailBuilder = FoodDetailBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        
        return FoodSearchRouter(interactor: interactor, viewController: component.FoodSearchVC, foodDetailBuildable: foodDetailBuilder)
    }
}
