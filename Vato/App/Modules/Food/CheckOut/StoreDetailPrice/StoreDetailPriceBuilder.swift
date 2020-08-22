//  File name   : StoreDetailPriceBuilder.swift
//
//  Author      : khoi tran
//  Created date: 12/25/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol StoreDetailPriceDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var mutableStoreStream: MutableStoreStream { get }

}

final class StoreDetailPriceComponent: Component<StoreDetailPriceDependency> {
    /// Class's public properties.
    let StoreDetailPriceVC: StoreDetailPriceVC
    
    /// Class's constructor.
    init(dependency: StoreDetailPriceDependency, StoreDetailPriceVC: StoreDetailPriceVC) {
        self.StoreDetailPriceVC = StoreDetailPriceVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol StoreDetailPriceBuildable: Buildable {
    func build(withListener listener: StoreDetailPriceListener) -> StoreDetailPriceRouting
}

final class StoreDetailPriceBuilder: Builder<StoreDetailPriceDependency>, StoreDetailPriceBuildable {
    /// Class's constructor.
    override init(dependency: StoreDetailPriceDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: StoreDetailPriceBuildable's members
    func build(withListener listener: StoreDetailPriceListener) -> StoreDetailPriceRouting {
        let vc = StoreDetailPriceVC(nibName: StoreDetailPriceVC.identifier, bundle: nil)
        let component = StoreDetailPriceComponent(dependency: dependency, StoreDetailPriceVC: vc)

        let interactor = StoreDetailPriceInteractor(presenter: component.StoreDetailPriceVC, mutableStoreStream: component.dependency.mutableStoreStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        
        return StoreDetailPriceRouter(interactor: interactor, viewController: component.StoreDetailPriceVC)
    }
}
