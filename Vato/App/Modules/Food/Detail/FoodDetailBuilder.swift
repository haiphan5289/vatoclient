//  File name   : FoodDetailBuilder.swift
//
//  Author      : Dung Vu
//  Created date: 10/29/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol FoodDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticated: AuthenticatedStream { get }
    var foodDetailProfile: ProfileStream { get }
    var mutableStoreStream: MutableStoreStream { get }
    var firebaseDatabase: DatabaseReference { get }
    var mutablePaymentStream: MutablePaymentStream { get }
}

final class FoodDetailComponent: Component<FoodDetailDependency> {
    /// Class's public properties.
    let FoodDetailVC: FoodDetailVC
    /// Class's constructor.
    init(dependency: FoodDetailDependency, FoodDetailVC: FoodDetailVC) {
        self.FoodDetailVC = FoodDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol FoodDetailBuildable: Buildable {
    func build(withListener listener: FoodDetailListener, item: FoodExploreItem) -> FoodDetailRouting
}

final class FoodDetailBuilder: Builder<FoodDetailDependency>, FoodDetailBuildable {
    /// Class's constructor.
    override init(dependency: FoodDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: FoodDetailBuildable's members
    func build(withListener listener: FoodDetailListener, item: FoodExploreItem) -> FoodDetailRouting {
        guard let vc = UIStoryboard(name: "FoodDetail", bundle: nil).instantiateInitialViewController() as? FoodDetailVC else {
            fatalError("Please Implement")
        }
        let component = FoodDetailComponent(dependency: dependency, FoodDetailVC: vc)

        let interactor = FoodDetailInteractor(presenter: component.FoodDetailVC, item: item, authenticated: component.dependency.authenticated, mutableStoreStream: component.dependency.mutableStoreStream, mutablePaymentStream: component.dependency.mutablePaymentStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let foodMapBuilder = FoodMapBuilder(dependency: component)
        let productMenuBuilder = ProductMenuBuilder(dependency: component)
        let checkOutBuilder = CheckOutBuilder(dependency: component)
        return FoodDetailRouter(interactor: interactor, viewController: component.FoodDetailVC, foodMapBuildable: foodMapBuilder, productMenuBuildable: productMenuBuilder, checkOutBuildable: checkOutBuilder)
    }
}
