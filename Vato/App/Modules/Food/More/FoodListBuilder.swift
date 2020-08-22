//  File name   : FoodListBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 11/5/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs

// MARK: Dependency tree
protocol FoodListDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var mProfileStream: ProfileStream { get }
    var mutableStoreStream: MutableStoreStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class FoodListComponent: Component<FoodListDependency> {
    /// Class's public properties.
    let FoodListVC: FoodListVC
    
    /// Class's constructor.
    init(dependency: FoodListDependency, FoodListVC: FoodListVC) {
        self.FoodListVC = FoodListVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodListBuildable: Buildable {
    func build(withListener listener: FoodListListener, type: FoodListType) -> FoodListRouting
}

final class FoodListBuilder: Builder<FoodListDependency>, FoodListBuildable {
    /// Class's constructor.
    override init(dependency: FoodListDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodListBuildable's members
    func build(withListener listener: FoodListListener, type: FoodListType) -> FoodListRouting {
        let vc = FoodListVC()
        vc.type = type
        let component = FoodListComponent(dependency: dependency, FoodListVC: vc)

        let interactor = FoodListInteractor(presenter: component.FoodListVC,
                                            type: type,
                                            authenticated: component.dependency.authenticated,
                                            mutableStoreStream: component.dependency.mutableStoreStream)
        interactor.listener = listener
        let foodDetailBuilder = FoodDetailBuilder(dependency: component)
        // todo: Create builder modules builders and inject into router here.
        let checkoutBuilder = CheckOutBuilder(dependency: component)
        return FoodListRouter(interactor: interactor, viewController: component.FoodListVC,
                              foodDetailBuildable: foodDetailBuilder,
                              checkOutBuildable: checkoutBuilder)
    }
}
