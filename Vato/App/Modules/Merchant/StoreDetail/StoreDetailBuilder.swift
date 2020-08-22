//  File name   : StoreDetailBuilder.swift
//
//  Author      : khoi tran
//  Created date: 11/6/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import FwiCore

// MARK: Dependency tree
protocol StoreDetailDependency: Dependency {
    // todo: Declare the set of dependencies required by this RIB, but cannot be created by this RIB.
    var authenticatedStream: AuthenticatedStream { get }
    var merchantDataStream: MerchantDataStream { get }
}

final class StoreDetailComponent: Component<StoreDetailDependency> {
    /// Class's public properties.
    let StoreDetailVC: StoreDetailVC
    
    /// Class's constructor.
    init(dependency: StoreDetailDependency, StoreDetailVC: StoreDetailVC) {
        self.StoreDetailVC = StoreDetailVC
        super.init(dependency: dependency)
    }
    
    /// Class's private properties.
    // todo: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: Builder
protocol StoreDetailBuildable: Buildable {
    func build(withListener listener: StoreDetailListener) -> StoreDetailRouting
}

final class StoreDetailBuilder: Builder<StoreDetailDependency>, StoreDetailBuildable {
    /// Class's constructor.
    override init(dependency: StoreDetailDependency) {
        super.init(dependency: dependency)
    }
    
    // MARK: StoreDetailBuildable's members
    func build(withListener listener: StoreDetailListener) -> StoreDetailRouting {
        let vc = StoreDetailVC(nibName: StoreDetailVC.identifier, bundle: nil)
        let component = StoreDetailComponent(dependency: dependency, StoreDetailVC: vc)

        let interactor = StoreDetailInteractor(presenter: component.StoreDetailVC, merchantStream: component.dependency.merchantDataStream, authStream: component.dependency.authenticatedStream)
        interactor.listener = listener

        // todo: Create builder modules builders and inject into router here.
        let addProductlBuilder = AddProductBuilder.init(dependency: component)
        let addStoreBuilder = AddStoreBuilder.init(dependency: component)
        let listProductBuilder = ListProductBuilder(dependency: component)
        return StoreDetailRouter(interactor: interactor, viewController: component.StoreDetailVC, addProductBuildable: addProductlBuilder, addStoreBuildable: addStoreBuilder, listProductBuildable: listProductBuilder)
    }
}

