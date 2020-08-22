//  File name   : StoreParentListBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 11/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol StoreParentListDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var mProfileStream: ProfileStream { get }
    var mutableStoreStream: MutableStoreStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class StoreParentListComponent: Component<StoreParentListDependency> {
    /// Class's public properties.
    let StoreParentListVC: StoreParentListVC
    
    /// Class's constructor.
    init(dependency: StoreParentListDependency, StoreParentListVC: StoreParentListVC) {
        self.StoreParentListVC = StoreParentListVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol StoreParentListBuildable: Buildable {
    func build(withListener listener: StoreParentListListener, list: [FoodCategoryItem]) -> StoreParentListRouting
}

final class StoreParentListBuilder: Builder<StoreParentListDependency>, StoreParentListBuildable {
    /// Class's constructor.
    override init(dependency: StoreParentListDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: StoreParentListBuildable's members
    func build(withListener listener: StoreParentListListener, list: [FoodCategoryItem]) -> StoreParentListRouting {
        let vc = StoreParentListVC()
        let component = StoreParentListComponent(dependency: dependency, StoreParentListVC: vc)

        let interactor = StoreParentListInteractor(presenter: component.StoreParentListVC, authenticated: component.dependency.authenticated, list: list)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let foodListCategoryBuildable = FoodListCategoryBuilder(dependency: component)
        let foodListBuildable = FoodListBuilder(dependency: component)
        
        return StoreParentListRouter(interactor: interactor,
                                     viewController: component.StoreParentListVC,
                                     foodListCategoryBuildable: foodListCategoryBuildable,
                                     foodListBuildable: foodListBuildable)
    }
}
